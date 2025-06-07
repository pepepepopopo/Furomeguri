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
  end

  private

  def search_nearby(location:, type:, poi_type:)
    request_url = "https://places.googleapis.com/v1/places/ChIJj61dQgK6j4AR4GeTYWZsKWw?fields=id,displayName&key=#{ENV['GOOGLE_MAP_API_KEY']}"
    search_nearby_params = 
  end
end
