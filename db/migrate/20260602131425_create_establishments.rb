class CreateEstablishments < ActiveRecord::Migration[8.1]
  def change
    create_table :establishments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :address
      t.string :category
      t.string :payment_methods
      t.string :opening_hours
      t.string :siret_siren

      t.timestamps
    end
  end
end
