class AddPurposeToCommunications < ActiveRecord::Migration[8.0]
  def change
    add_column :communications, :purpose, :string unless column_exists?(:communications, :purpose)
  end
end
