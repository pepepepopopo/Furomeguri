class ItineraryBlocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary
  before_action :set_block, only: %i[update destroy]

  def create
    place = Place.find_or_create_by!(google_place_id: block_params[:google_place_id]) do |p|
      p.name = block_params[:name]
      p.lat  = block_params[:lat]
      p.lng  = block_params[:lng]
    end

    @block = @itinerary.itinerary_blocks.create!(
      place: place,
      description: block_params[:description],
      starttime: parse_time(block_params[:starttime])
    )

    render turbo_stream: turbo_stream.append(
      "sidebar-items",
      partial: "shared/block",
      locals: { block: @block }
    )
  end

  def update
    if @block.update(
      description: block_params[:description],
      starttime: parse_time(block_params[:starttime])
    )
      head :ok
    else
      head :unprocessable_entity
    end
  end

  # DELETE /itinerary_blocks/:id
  def destroy
    @block.destroy!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("block_#{@block.id}") }
      format.html         { redirect_back fallback_location: itinerary_path(@itinerary) }
    end
  end

  private

  def set_itinerary
    @itinerary = current_user.itineraries.find(params[:itinerary_id])
  end

  def set_block
    @block = @itinerary.itinerary_blocks.find(params[:id])
  end

  def block_params
    params.require(:itinerary_block)
      .permit(:google_place_id, :name, :lat, :lng, :description, :starttime)
  end

  # 文字列(YYYY-MM-DDTHH:MM) → Time.zone
  def parse_time(raw)
    return nil if raw.blank?

    Time.zone.parse(raw.to_s)
  rescue ArgumentError
    nil
  end
end
