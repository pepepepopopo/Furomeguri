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

  # google map apiでの検索
  def text_search(location, accommodation_type, poi_type, keyword)
    api_key = ENV.fetch("GOOGLE_PLACE_API_KEY", nil) # 環境変数からAPIキーを取得
    uri = URI.parse("https://places.googleapis.com/v1/places:searchText")

    # 引数をリクエストボディ用に加工
    # 緯度
    location_latitude = DefaultLocation.find_by(name: location).lat
    # 経度
    location_longitude = DefaultLocation.find_by(name: location).lng
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
  def hotel_search()
  end
end
