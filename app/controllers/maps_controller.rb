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
    @accommodation_type = params[:accommodation_type]
    @poi_type = params[:poi_type]
    @keyword = params[:keyword]

    # デバッグログ
    Rails.logger.info "=== MapsController#location_search ==="
    Rails.logger.info "All params: #{params.inspect}"
    Rails.logger.info "API Type: #{@api_type}"
    Rails.logger.info "Location: #{@location}"

    # 絞り込み条件パラメータ
    @min_price = params[:min_price]
    @max_price = params[:max_price]
    @amenities = extract_amenities(params)

    # locationパラメータの検証
    if @location.blank?
      render json: { error: "Location parameter is required" }, status: :bad_request
      return
    end

    places = case @api_type
             when 'google'
               Rails.logger.info "Google API branch selected"
               text_search(@location, @accommodation_type, @poi_type, @keyword)
             when 'rakuten'
               Rails.logger.info "Rakuten API branch selected"
               raw_results = hotel_search(@location)
               filter_rakuten_results(raw_results)
             else
               Rails.logger.info "No API type matched, api_type: #{@api_type.inspect}"
               { error: "Invalid or missing api_type parameter" }
             end
    render json: places
  end

  private

  # google map apiでの検索
  def text_search(location, accommodation_type, poi_type, keyword)
    api_key = ENV.fetch("GOOGLE_PLACE_API_KEY", nil)
    uri = URI.parse("https://places.googleapis.com/v1/places:searchText")

    # 引数をリクエストボディ用に加工
    location_data = DefaultLocation.find_by(name: location)
    return { error: "Location not found" } unless location_data

    # 緯度・経度
    location_latitude = location_data.lat
    location_longitude = location_data.lng
    # textQueryの構築
    query_parts = []

    # 宿泊施設タイプを追加
    if accommodation_type == "旅館・ホテル"
      query_parts << "ホテル 旅館"
    end

    # 周辺施設タイプを追加
    if poi_type == "飲食・観光地"
      query_parts << "レストラン 観光地"
    end

    # キーワードを追加
    query_parts << keyword if keyword.present?

    # 温泉地名を常に含める
    query_parts << location

    textquery_keyword = query_parts.compact.join(" ")
    textquery_keyword = location if textquery_keyword.blank?
    
    # デバッグログの追加
    Rails.logger.info "=== Google Places API Request Debug ==="
    Rails.logger.info "Location: #{location}"
    Rails.logger.info "Accommodation type: #{accommodation_type}"
    Rails.logger.info "POI type: #{poi_type}"
    Rails.logger.info "Keyword: #{keyword}"
    Rails.logger.info "Query parts: #{query_parts.inspect}"
    Rails.logger.info "Final textquery_keyword: #{textquery_keyword}"
    Rails.logger.info "Location data: lat=#{location_latitude}, lng=#{location_longitude}"
    
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
    
    Rails.logger.info "Request body: #{request_body.to_json}"

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
    
    Rails.logger.info "=== Google Places API Response ==="
    Rails.logger.info "Response code: #{response.code}"
    Rails.logger.info "Response body: #{response.body[0..1000]}..." # 最初の1000文字だけログ出力

    if response.code == "200"
      parsed_response = JSON.parse(response.body)
      Rails.logger.info "Parsed response keys: #{parsed_response.keys if parsed_response.is_a?(Hash)}"
      Rails.logger.info "Places count: #{parsed_response.dig('places')&.length || 0}"
      parsed_response
    else
      @error = "API request failed with status code: #{response.code}"
      Rails.logger.error "API Error: #{@error}"
      Rails.logger.error "Response body: #{response.body}"
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

    request = Net::HTTP::Get.new(uri)
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

  # こだわり条件パラメータの抽出
  def extract_amenities(params)
    amenity_keys = ['源泉かけ流し', '大浴場', 'サウナ', '露天風呂', '海が見える', '貸し切り風呂', '客室露天風呂']
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
end
