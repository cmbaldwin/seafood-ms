class AddEggyToOysterStock < ActiveRecord::Migration[5.2]
  def change
    add_column :oyster_stocks, :eggy, :decimal
  end
end
