class Itinerary < ApplicationRecord
  belongs_to :user, optional: true
  has_many :itinerary_blocks, dependent: :destroy
end
