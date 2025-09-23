class MapsController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  def index
    @default_locations = DefaultLocation.all
  end

  def location_search
    @location = params[:location]
    @api_type = params[:api_type]
    @keyword = params[:keyword]

    # 絞り込み条件パラメータ
    @min_price = params[:min_price]
    @max_price = params[:max_price]
    @amenities = extract_amenities_by_api_type(@api_type, params)

    # locationパラメータの検証
    if @location.blank?
      render json: { error: "Location parameter is required" }, status: :bad_request
      return
    end

    places = case @api_type
             when 'google'
               text_search(@location, @keyword, @amenities)
             when 'rakuten'
               raw_results = hotel_search(@location)
               filter_rakuten_results(raw_results)
             when 'hotpepper'
               food_search(location, keyword, amenities)
             else
               { error: "Invalid or missing api_type parameter" }
             end
    render json: places
  end

  private

  # google map apiでの検索
  def text_search(location, keyword, amenities)
    api_key = ENV.fetch("GOOGLE_PLACE_API_KEY", nil)
    uri = URI.parse("https://places.googleapis.com/v1/places:searchText")

    # 引数をリクエストボディ用に加工
    location_data = DefaultLocation.find_by(name: location)
    return { error: "Location not found" } unless location_data

    # 緯度・経度
    location_latitude = location_data.lat
    location_longitude = location_data.lng

    # textQueryの構築（keywordとamenitiesベース）
    query_parts = []

    # 温泉地名を常に含める
    query_parts << location

    # キーワードを追加
    query_parts << keyword if keyword.present?

    # こだわり条件を追加
    amenities.each { |amenity| query_parts << amenity }

    textquery_keyword = query_parts.compact.join(" ")
    textquery_keyword = location if textquery_keyword.blank?

    # リクエストボディの構築
    request_body = {
      textQuery: textquery_keyword,
      pageSize: 20,
      languageCode: "ja",
      locationBias: {
        circle: {
          center: {
            latitude: location_latitude,
            longitude: location_longitude
          },
          radius: 500.0
        }
      }
    }

    # HTTP POSTリクエストの作成
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true # HTTPSを使用する場合

    request = Net::HTTP::Post.new(uri.path)
    headers = {
      'Content-Type': "application/json",
      'X-Goog-Api-Key': api_key,
      'X-Goog-FieldMask': "places.id,places.location,places.displayName,places.formattedAddress"
    }
    headers.each { |key, value| request[key.to_s] = value }

    request.body = request_body.to_json

    # リクエストの送信とレスポンスの処理
    response = http.request(request)
    response.body.force_encoding("UTF-8")

    if response.code == "200"
      JSON.parse(response.body)

    else
      @error = "API request failed with status code: #{response.code}"
      render json: { error: @error }, status: :internal_server_error
    end
  end

  # 楽天トラベルAPIでの検索
  def hotel_search(location)
    app_id = ENV.fetch("RAKUTEN_APPLICATION_ID")
    location_data = DefaultLocation.find_by(name: location)

    return { error: "Location not found" } unless location_data

    # APIパラメータ
    params = {
      applicationId: app_id,
      format: "json",
      latitude: location_data.lat,
      longitude: location_data.lng,
      searchRadius: 3,
      datumType: 1,
      allReturnFlag: 1
    }

    uri = URI.parse("https://app.rakuten.co.jp/services/api/Travel/SimpleHotelSearch/20170426")
    uri.query = URI.encode_www_form(params)

    # HTTPリクエスト実行
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::GET.new(uri)
    response = http.request(request)

    if response.code == "200"
      data = JSON.parse(response.body)
      # Google Places APIと同様の形式に変換
      {
        hotels: data["hotels"] || [],
        total_count: data.dig("pagingInfo", "recordCount") || 0
      }
    else
      { error: "Rakuten API request failed with status code: #{response.code}" }
    end
  rescue StandardError => e
    { error: "Rakuten API error: #{e.message}" }
  end

  def sort_hotel_response(data); end

  # API種別に応じたこだわり条件パラメータの抽出
  def extract_amenities_by_api_type(api_type, params)
    amenity_keys = case api_type
                   when 'google'
                     ['城', '景観地', '公園']
                   when 'rakuten'
                     ['源泉かけ流し', '大浴場', 'サウナ', '露天風呂', '海が見える', '貸し切り風呂', '客室露天風呂']
                   else
                     ['lunch', 'parking', 'sake', 'shochu', 'wine', 'private_room']
                   end

    amenity_keys.select { |key| params[key].present? }
  end

  # 楽天トラベルAPI結果の絞り込み
  def filter_rakuten_results(results)
    return results if results.is_a?(Hash) && results[:error]

    hotels = results[:hotels] || []

    filtered_hotels = hotels.select do |hotel|
      hotel_info = hotel.dig('hotel', 0, 'hotelBasicInfo')
      next false unless hotel_info

      # 価格絞り込み
      next false unless price_in_range?(hotel_info)

      # こだわり条件絞り込み
      next false unless amenities_match?(hotel_info)

      true
    end

    { hotels: filtered_hotels, total_count: filtered_hotels.size }
  end

  # 価格範囲チェック
  def price_in_range?(hotel_info)
    return true if @min_price.blank? && @max_price.blank?

    price = hotel_info['hotelMinCharge']&.to_i
    return true if price.nil?

    min_ok = @min_price.blank? || price >= @min_price.to_i
    max_ok = @max_price.blank? || price <= @max_price.to_i

    min_ok && max_ok
  end

  # こだわり条件マッチング
  def amenities_match?(hotel_info)
    return true if @amenities.empty?

    # ホテル名、説明、設備情報を結合して検索対象とする
    searchable_text = [
      hotel_info['hotelName'],
      hotel_info['hotelSpecial'],
      hotel_info['hotelComment']
    ].compact.join(' ')

    # 全てのこだわり条件が含まれているかチェック
    @amenities.all? do |amenity|
      searchable_text.include?(amenity)
    end
  end

  def food_search(location, keyword, _amenities)
    key = ENV.fetch("HOT_PEPPER_API_KEY")
    uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/")

    location_data = DefaultLocation.find_by(name: location)
    return { error: "Location not found" } unless location_data

    location_latitude = location_data.lat
    location_longitude = location_data.lng

    params = {
      key: key,
      format: 'json',
      lat: location_latitude,
      lng: location_longitude,
      range: 3
    }

    params[:genre] = genre if genre.present?
    params[:keyword] = keyword if keyword.present?

    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::GET.new(uri)
    response = http.request(request)

    if response.code == "200"
      JSON.parse(response.body)
      # Google Places APIと同様の形式に変換

    end
  end
end
