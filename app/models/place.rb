class Place < ApplicationRecord
  has_many :itinerary_blocks, dependent: :nullify
  validates :google_place_id, presence: true, uniqueness: true
end
