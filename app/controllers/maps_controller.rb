class MapsController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  def index
    @default_locations = DefaultLocation.all
  end

  def location_search
    @location = params[:location]
    @accommodation_type = params[:accommodation_type]
    @poi_type = params[:poi_type]
    @keyword = params[:keyword]

    if @location.present?
      places = text_search(@location, @accommodation_type, @poi_type, @keyword)
      render json: places
    else
      Rails.logger.warn
    end
  end

  private

  def text_search(location, accommodation_type, poi_type, keyword)
    api_key = ENV["GOOGLE_PLACE_API_KEY"] # 環境変数からAPIキーを取得
    uri = URI.parse("https://places.googleapis.com/v1/places:searchText")

    # 引数をリクエストボディ用に加工
    # 緯度
    locationLatitude = DefaultLocation.find_by(name: location).lat
    # 経度
    locationLongitude = DefaultLocation.find_by(name: location).lng
    # 宿泊施設タイプをtextQueryに設定
    if accommodation_type == "旅館・ホテル"
      textQuery_accommodation = "ホテル,旅館"
    end
    # 周辺施設タイプをtextQueryに設定
    if poi_type == "飲食・観光地"
      textQuery_poi_type = "飲食,観光地"
    end
    # textQueryの作成
    textQuery_keyword = "#{textQuery_accommodation},#{textQuery_poi_type},#{keyword}"
    # リクエストボディの構築
    request_body = {
      textQuery: textQuery_keyword,
      pageSize: 2,
      languageCode: "ja",
      locationBias: {
        circle: {
          center: {
            latitude: locationLatitude,
            longitude: locationLongitude
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
    response_body = response.body.force_encoding("UTF-8")

    if response.code == "200"
      searched_location = JSON.parse(response.body)
      Rails.logger.info "✅ Parsed places: #{searched_location}"
      searched_location
    else
      @error = "API request failed with status code: #{response.code}"
      Rails.logger.error "❌ #{@error}"
      render json: { error: @error }, status: :internal_server_error
    end
  end
end
