class CreateInitialTables < ActiveRecord::Migration
  def change
    create_table :exchanges do |t|
      t.datetime :created_at, null: false
      t.string :transaction_id, null: false
      t.integer :initial_btc_satoshis, default: 0, null: false
      t.string :initial_btc_currency, default: "BTC", null: false
      t.monetize :exchanged_usd, null: false
      t.monetize :fee_usd, null: false
    end

    create_table :donations do |t|
      t.datetime :created_at, null: false
      t.string :transaction_id, null: false
      t.string :charity_name, null: false
      t.monetize :withdrawn_usd, null: false
      t.monetize :donated_usd, null: false
      t.monetize :fee_usd, null: false
    end
  end
end
