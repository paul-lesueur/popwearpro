class AddArchivedAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :archived_at, :datetime
  end
end
