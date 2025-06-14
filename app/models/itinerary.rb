class Itinerary < ApplicationRecord
  belongs_to :user, optical: true
  has_many :itinerary_block, dependent: :destroy
end
