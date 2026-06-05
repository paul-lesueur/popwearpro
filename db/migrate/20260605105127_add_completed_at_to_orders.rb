class AddCompletedAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :completed_at, :datetime
  end
end
