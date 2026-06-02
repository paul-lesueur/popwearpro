class CreateCommunications < ActiveRecord::Migration[8.1]
  def change
    create_table :communications do |t|
      t.references :order, null: false, foreign_key: true
      t.string :channel
      t.string :status
      t.text :content
      t.datetime :sent_at

      t.timestamps
    end
  end
end
