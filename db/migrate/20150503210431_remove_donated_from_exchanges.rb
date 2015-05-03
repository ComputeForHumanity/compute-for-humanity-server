class RemoveDonatedFromExchanges < ActiveRecord::Migration
  def change
    remove_column :exchanges, :donated, :boolean, default: false, null: false
  end
end
