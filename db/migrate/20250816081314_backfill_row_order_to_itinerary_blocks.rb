class BackfillRowOrderToItineraryBlocks < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!
  def up
    ItineraryBlock.unscoped.in_batches do |relation|
      relation.update_all("row_order = EXTRACT(EPOCH FROM created_at)")
      sleep(0.01)
    end
  end
end
