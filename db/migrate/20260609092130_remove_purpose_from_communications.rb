class RemovePurposeFromCommunications < ActiveRecord::Migration[8.1]
  def change
    remove_column :communications, :purpose, :string
  end
end
