class AddIconToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :icon, :string
  end
end
