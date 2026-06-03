class RemoveCategoryFromItems < ActiveRecord::Migration[8.1]
  def change
    # On abandonne la distinction prestation/article : le catalogue ne contient
    # plus que des prestations, la colonne category n'a plus de raison d'être.
    remove_column :items, :category, :string
  end
end
