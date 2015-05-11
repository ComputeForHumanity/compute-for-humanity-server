class UpdateSchemaForDonations < ActiveRecord::Migration
  def change
    create_table :dwolla_secrets do |t|
      t.string :refresh_token, null: false
      t.string :encrypted_pin, null: false
      t.string :encrypted_pin_salt, null: false
      t.string :encrypted_pin_iv, null: false
    end

    rename_column :donations, :withdrawn_usd_cents, :initial_usd_cents
    rename_column :donations, :withdrawn_usd_currency, :initial_usd_currency
    add_column :donations, :status, :string

    change_column_null :donations, :transaction_id, true
  end
end
