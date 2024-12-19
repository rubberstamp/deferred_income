class AddUniqueIndexToChargesTransactionId < ActiveRecord::Migration[8.0]
  def change
    add_index :charges, [:team_id, :transaction_id], unique: true
  end
end
