class AddItineraryReferenceToItineraryBlocks < ActiveRecord::Migration[7.2]
  def change
    add_reference :itinerary_blocks, :itinerary, null: false, foreign_key: true
  end
end
