class AddAnonymousToCustomers < ActiveRecord::Migration[8.1]
  def change
    # Client anonyme (vente comptoir) : pas d'identité requise, juste une référence ANON-xxxxx.
    add_column :customers, :is_anonymous, :boolean, default: false, null: false
    add_column :customers, :anon_ref, :string
    add_index :customers, :anon_ref, unique: true
    # Les colonnes d'identité (firstname, lastname, ...) sont déjà nullables :
    # la contrainte "obligatoire pour un client nommé" est gérée par validation applicative.
  end
end
