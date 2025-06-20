class ItineraryBlocksController < ApplicationController
  before_action :set_itinerary
  before_action :set_block, only: %i[update destroy]

  # POST /itineraries/:itinerary_id/itinerary_blocks
  def create
    place = Place.find_or_create_by!(google_place_id: block_params[:google_place_id]) do |p|
      p.name = block_params[:name]
      p.lat  = block_params[:lat]
      p.lng  = block_params[:lng]
    end

    @block = @itinerary.itinerary_blocks.create!(
      place:       place,
      description: block_params[:description],
      starttime:   block_params[:starttime],
      position:    @itinerary.itinerary_blocks.maximum(:position).to_i + 1
    )

    render turbo_stream: turbo_stream.append(
      "sidebar-items",
      partial: "shared/block",
      locals:  { block: @block }
    )
  end

  # PATCH /itinerary_blocks/:id
  def update
    if @block.update(block_params.slice(:description, :starttime))
      head :ok
    else
      head :unprocessable_entity
    end
  end

  # DELETE /itinerary_blocks/:id
  def destroy
    @block.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("block_#{@block.id}")
      end
      format.html { redirect_back fallback_location: itinerary_path(@block.itinerary)}
    end
  end

  private

  def set_itinerary
    @itinerary = Itinerary.find(params[:itinerary_id])
  end

  def set_block
    @block = ItineraryBlock.find(params[:id])
  end

  def block_params
    params.require(:itinerary_block)
          .permit(:google_place_id, :name, :lat, :lng, :description, :starttime)
  end
end
