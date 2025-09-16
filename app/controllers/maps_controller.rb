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

    # 検索パラメータのログ出力
    Rails.logger.info "=== 検索パラメータ ==="
    Rails.logger.info "温泉地: #{@location}"
    Rails.logger.info "API種別: #{@api_type}"
    Rails.logger.info "キーワード: #{@keyword}"
    Rails.logger.info "こだわり条件: #{@amenities.inspect}"
    Rails.logger.info "価格範囲: #{@min_price} - #{@max_price}"

    # locationパラメータの検証
    if @location.blank?
      render json: { error: "Location parameter is required" }, status: :bad_request
      return
    end

    places = case @api_type
             when 'google'
               Rails.logger.info "Google API branch selected"
               text_search(@location, @keyword, @amenities)
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

    # 検索クエリのログ出力
    Rails.logger.info "=== Google Places API検索クエリ ==="
    Rails.logger.info "構築されたクエリパーツ: #{query_parts.inspect}"
    Rails.logger.info "最終検索クエリ: '#{textquery_keyword}'"

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

    # リクエスト詳細のログ出力
    Rails.logger.info "=== Google Places API リクエスト詳細 ==="
    Rails.logger.info "URL: #{uri}"
    Rails.logger.info "リクエストボディ: #{request_body.to_json}"
    Rails.logger.info "ヘッダー: #{headers.inspect}"

    # リクエストの送信とレスポンスの処理
    Rails.logger.info "=== API リクエスト送信中 ==="
    response = http.request(request)
    Rails.logger.info "レスポンスコード: #{response.code}"
    response.body.force_encoding("UTF-8")

    if response.code == "200"
      parsed_response = JSON.parse(response.body)
      places_count = parsed_response.dig("places")&.length || 0
      Rails.logger.info "=== API レスポンス成功 ==="
      Rails.logger.info "取得した場所数: #{places_count}"
      if places_count > 0
        Rails.logger.info "場所一覧:"
        parsed_response["places"]&.each_with_index do |place, index|
          name = place.dig("displayName", "text") || "名称未取得"
          Rails.logger.info "  #{index + 1}. #{name}"
        end
      end
      parsed_response
    else
      Rails.logger.error "=== API レスポンス失敗 ==="
      Rails.logger.error "ステータスコード: #{response.code}"
      Rails.logger.error "レスポンスボディ: #{response.body}"
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

  # API種別に応じたこだわり条件パラメータの抽出
  def extract_amenities_by_api_type(api_type, params)
    case api_type
    when 'google'
      amenity_keys = ['城', '景観地', '公園']
    when 'rakuten'
      amenity_keys = ['源泉かけ流し', '大浴場', 'サウナ', '露天風呂', '海が見える', '貸し切り風呂', '客室露天風呂']
    else
      amenity_keys = []
    end

    selected_amenities = amenity_keys.select { |key| params[key].present? }
    Rails.logger.info "抽出されたこだわり条件: #{selected_amenities.inspect}"
    selected_amenities
  end

  # こだわり条件パラメータの抽出（楽天API用、後方互換性のため保持）
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
