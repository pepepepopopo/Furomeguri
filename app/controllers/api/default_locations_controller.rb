class Api::DefaultLocationsController < ApplicationController
  def index
    location = DefaultLocation.all
    render json: location
  end
end
