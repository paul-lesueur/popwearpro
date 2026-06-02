class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :establishment, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :status
      t.string :priority
      t.date :due_date
      t.string :payment_method
      t.string :payment_status
      t.datetime :paid_at
      t.datetime :collected_at
      t.text :internal_notes

      t.timestamps
    end
  end
end
