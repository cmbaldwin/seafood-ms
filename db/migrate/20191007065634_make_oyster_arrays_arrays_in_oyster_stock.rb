class MakeOysterArraysArraysInOysterStock < ActiveRecord::Migration[5.2]
  def change
    remove_column :oyster_stocks, :large
    remove_column :oyster_stocks, :medium
    remove_column :oyster_stocks, :small
    remove_column :oyster_stocks, :shells
    remove_column :oyster_stocks, :eggy
    add_column :oyster_stocks, :large, :text, array: true, default: []
    add_column :oyster_stocks, :medium, :text, array: true, default: []
    add_column :oyster_stocks, :small, :text, array: true, default: []
    add_column :oyster_stocks, :shells, :text, array: true, default: []
    add_column :oyster_stocks, :eggy, :text, array: true, default: []
  end
end
