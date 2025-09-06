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

    # locationパラメータの検証
    if @location.blank?
      render json: { error: "Location parameter is required" }, status: :bad_request
      return
    end

    places = case @api_type
             when 'google'
               text_search(@location, @accommodation_type, @poi_type, @keyword)
             when 'rakuten'
               hotel_search(@location)
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
    # 宿泊施設タイプをtextQueryに設定
    textquery_accommodation = "ホテル,旅館" if accommodation_type == "旅館・ホテル"
    # 周辺施設タイプをtextQueryに設定
    textquery_poi_type = "飲食,観光地" if poi_type == "飲食・観光地"
    # textQueryの作成
    textquery_keyword = "#{textquery_accommodation},#{textquery_poi_type},#{keyword}"
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

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    if response.code == "200"
      data = JSON.parse(response.body)
      # Google Places APIと同様の形式に変換
      {
        hotels: data("hotels") || [],
        total_count: data.dig("pagingInfo", "recordCount") || 0
      }
    else
      { error: "Rakuten API request failed with status code: #{response.code}" }
    end
  rescue StandardError => e
    { error: "Rakuten API error: #{e.message}" }
  end
end
