class RemoveKindFromCommunications < ActiveRecord::Migration[8.1]
  def change
    remove_column :communications, :kind, :string
  end
end
