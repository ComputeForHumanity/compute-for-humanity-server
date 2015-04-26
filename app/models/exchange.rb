class Exchange < ActiveRecord::Base
  validates :transaction_id, presence: true

  monetize :initial_btc_satoshis,
           as: :initial_btc,
           with_currency: :btc,
           numericality: { greater_than_or_equal_to: 0 }
  monetize :exchanged_usd_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :fee_usd_cents, numericality: { greater_than_or_equal_to: 0 }
end
