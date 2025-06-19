class RenameItinerariyBlocksToItineraryBlocks < ActiveRecord::Migration[7.2]
  def change
    rename_table :itinerariy_blocks, :itinerary_blocks
  end
end
