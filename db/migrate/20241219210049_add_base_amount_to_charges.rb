class AddBaseAmountToCharges < ActiveRecord::Migration[8.0]
  def change
    add_column :charges, :amount_cents, :integer
  end
end
