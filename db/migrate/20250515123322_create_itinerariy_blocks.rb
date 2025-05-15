class CreateItinerariyBlocks < ActiveRecord::Migration[7.2]
  def change
    create_table :itinerariy_blocks do |t|
      t.references :place, null: false, foreign_key: true
      t.datetime :starttime
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
