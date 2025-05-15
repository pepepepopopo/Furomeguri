class CreateItineraries < ActiveRecord::Migration[7.2]
  def change
    create_table :itineraries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :itinerariy_block, null: false, foreign_key: true
      t.text :title
      t.text :subtitle

      t.timestamps
    end
  end
end
