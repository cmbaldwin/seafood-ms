class AddAmToOysterStock < ActiveRecord::Migration[5.2]
  def change
    add_column :oyster_stocks, :am, :boolean
  end
end
