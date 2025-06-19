class ChangeUserIdNullOnItineraries < ActiveRecord::Migration[7.2]
  def change
    change_column_null :itineraries, :user_id, true
  end
end
