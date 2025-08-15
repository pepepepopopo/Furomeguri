class ReplacePositionWithRowOrderInItineraryBlocks < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    add_column :itinerary_blocks, :row_order, :integer

    ItineraryBlock.unscoped.in_batches do |relation|
      relation.update_all("row_order = position")
      sleep(0.01)
    end

    remove_column :itinerary_blocks, :position
  end

  def down
    add_column :itinerary_blocks, :position, :integer

    ItineraryBlock.unscoped.in_batches do |relation|
      relation.update_all("position = row_order")
      sleep(0.01)
    end

    remove_column :itinerary_blocks, :row_order
  end
end
