class AddEmailConfirmationToOrders < ActiveRecord::Migration[8.1]
  def change
    # Défaut true : conserve le comportement actuel (email envoyé) tant que le
    # client n'a pas explicitement décoché le toggle dans le formulaire.
    add_column :orders, :email_confirmation, :boolean, default: true, null: false
  end
end
