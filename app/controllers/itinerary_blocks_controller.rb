class ItineraryBlocksController < ApplicationController

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
  end

  def update
    @block = ItineraryBlock.find(params[:id])
    if @block.update(itinerary_block_params)
      head: :ok
    else
      head: :unprocessable_entity
    end
  end

  def destroy
    block = ItineraryBlock.find(params[:id])
    block.destroy!
  end

  private
  def itinerary_block_params
    params.require(:block).permit(:google_place_id, :name, :description, :starttime)
  end
end
