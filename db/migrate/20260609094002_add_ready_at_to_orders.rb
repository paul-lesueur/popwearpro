class AddReadyAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :ready_at, :datetime
  end
end
