class AddNullToItineraryTitle < ActiveRecord::Migration[7.2]
  def change
    change_column_null :itineraries, :title, false
    change_column_default :itineraries, :title, from: nil, to: "タイトル未定"
  end
end
