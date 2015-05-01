class EnforcePayoutDate < ActiveRecord::Migration
  def change
    change_column_null :exchanges, :payout_date, false
    change_column_null :exchanges, :complete, false
    change_column_null :exchanges, :donated, false
  end
end
