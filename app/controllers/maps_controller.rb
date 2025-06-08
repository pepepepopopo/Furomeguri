class MapsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    @default_locations = DefaultLocation.all

    @location = params[:location]
    @accommodation_type = params[:accommodation_type]
    @poi_type = params[:poi_type]
    @keyword = params[:keyword]

    Rails.logger.info "📍Location: #{@location}"
    Rails.logger.info "🏨Accommodation Type: #{@accommodation_type}"
    Rails.logger.info "📌POI Type: #{@poi_type}"
    Rails.logger.info "🔍Keyword: #{@keyword}"

    if @location.present?
      @places = nearby_search(@location, @accommodation_type, @poi_type, @keyword)
    else
      Rails.logger.warn
    end
  end

  private

  def nearby_search(location, accommodation_type, poi_type, keyword)
    api_key = ENV['GOOGLE_PLACE_API_KEY'] # 環境変数からAPIキーを取得
    uri = URI.parse("https://places.googleapis.com/v1/places:searchText")

    # 引数をリクエストボディ用に加工
      # 緯度
    locationLatitude = DefaultLocation.find_by( name: location ).lat
      # 経度
    locationLongitude = DefaultLocation.find_by( name: location ).lng
      # 宿泊施設タイプを設定
    IncludedTypesAccommodation =
      # 周辺施設タイプを設定
    IncludedTypesPoi_type =
      # キーワード

    # リクエストボディの構築
    request_body = {
      textQuery: "レストラン"
      includedTypes: ["restaurant"],
      locationBias: {
        circle: {
          center: {
            latitude: 36.62303436838449,
            longitude: 138.59697281955727
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
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': api_key,
      'X-Goog-FieldMask': 'places.displayName,places.formattedAddress'
    }
    headers.each { |key, value| request[key.to_s] = value }

    request.body = request_body.to_json

    # リクエストのログ出力
    Rails.logger.info "🌐 Sending POST request to: #{uri}"
    Rails.logger.info "📤 Request headers: #{headers}"
    Rails.logger.info "📤 Request body: #{request_body.to_json}"

    # リクエストの送信とレスポンスの処理
    response = http.request(request)

    # レスポンスのログ出力
    Rails.logger.info "📥 Response status code: #{response.code}"
    Rails.logger.info "📥 Response body: #{response.body.force_encoding('UTF-8')}"

    if response.code == '200'
      @places = JSON.parse(response.body)['places']
      Rails.logger.info "✅ Parsed places: #{@places}"
      render json: @places
    else
      @error = "API request failed with status code: #{response.code}"
      Rails.logger.error "❌ #{@error}"
      render json: { error: @error }, status: :internal_server_error
    end
  end

end
