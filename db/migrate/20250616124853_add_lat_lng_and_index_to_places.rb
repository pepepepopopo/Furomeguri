class AddLatLngAndIndexToPlaces < ActiveRecord::Migration[7.2]
  def change
    add_column :places, :lat, :float
    add_column :places, :lng, :float

    change_column :places, :google_place_id, :string
    add_index :places, :google_place_id, unique: true
  end
end
