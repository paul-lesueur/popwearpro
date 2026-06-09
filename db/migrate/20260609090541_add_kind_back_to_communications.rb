class AddKindBackToCommunications < ActiveRecord::Migration[8.1]
  def change
    add_column :communications, :kind, :string
  end
end
