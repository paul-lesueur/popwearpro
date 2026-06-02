class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :establishment, null: false, foreign_key: true
      t.string :category
      t.string :name
      t.decimal :price_ht
      t.decimal :vat_rate
      t.boolean :repair_bonus
      t.string :photo_url
      t.boolean :active

      t.timestamps
    end
  end
end
