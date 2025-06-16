class ItineraryBlocksController < ApplicationController

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    @block = @itinerary.itinerary_blocks.build(itinerary_block_params)
    @block.save!

    render turbo_stream: turbo_stream.replace(
      'sidebar_frame',
      partial: 'sidebars/sidebar',
      local: {
        itinerary: @itinerary,
        blocks: @itinerary.itinerary_blocks.order(:created_at)
      }
    )
  end

  def update
    @block = ItineraryBlock.find(params[:id])
    if @block.update(itinerary_block_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def destroy
    block = ItineraryBlock.find(params[:id])
    block.destroy!
  end

  private
  def itinerary_block_params
    params.require(:itinerary_blocks).permit(:google_place_id, :name, :lat, :lng, :description, :starttime)
  end
end
