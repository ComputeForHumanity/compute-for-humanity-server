class AddPayoutDate < ActiveRecord::Migration
  def change
    add_column :exchanges, :payout_date, :datetime
    add_column :exchanges, :complete, :boolean, default: false
    add_column :exchanges, :donated, :boolean, default: false
  end
end
