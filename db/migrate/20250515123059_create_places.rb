class CreatePlaces < ActiveRecord::Migration[7.2]
  def change
    create_table :places do |t|
      t.text :google_place_id
      t.text :name

      t.timestamps
    end
  end
end
