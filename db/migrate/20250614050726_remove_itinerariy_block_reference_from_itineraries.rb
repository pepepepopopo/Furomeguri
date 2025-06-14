class RemoveItinerariyBlockReferenceFromItineraries < ActiveRecord::Migration[7.2]
  def change
    remove_reference :itineraries, :itinerariy_block, null: false, foreign_key: true
  end
end
