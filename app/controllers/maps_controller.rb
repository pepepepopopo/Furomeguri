class MapsController < ApplicationController
  def index
    @default_locations = DefaultLocation.all
  end
end
