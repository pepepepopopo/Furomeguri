class ItineraryBlock < ApplicationRecord
  belongs_to :itinerary
  belongs_to :place

  include RankedModel
  ranks :row_order
end
