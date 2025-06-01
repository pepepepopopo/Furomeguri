class CreateDefaultLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :default_locations do |t|
      t.string :name
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
