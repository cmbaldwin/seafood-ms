class DropTablesOysterStocksAndOysterPayments < ActiveRecord::Migration[5.2]
  def change
  	drop_table :supplies
  	drop_table :oyster_stocks
  	drop_table :oyster_payments
  end
end
