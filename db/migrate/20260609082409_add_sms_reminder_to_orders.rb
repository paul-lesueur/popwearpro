class AddSmsReminderToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :sms_reminder, :boolean, default: false, null: false
  end
end
