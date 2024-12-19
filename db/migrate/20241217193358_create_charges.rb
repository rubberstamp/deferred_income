class CreateCharges < ActiveRecord::Migration[8.0]
  def change
    create_table :charges do |t|
      t.string :source
      t.string :transaction_id
      t.string :split_transaction_id
      t.date :booked_date
      t.date :recognition_start_date
      t.date :recognition_end_date
      t.decimal :amount
      t.string :currency
      t.text :description

      t.timestamps
    end
  end
end
