class AddDataToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :data, :text
  end
end
