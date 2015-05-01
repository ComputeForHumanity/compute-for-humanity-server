class Withdrawal < ActiveRecord::Base
  validates :transaction_id, presence: true

  monetize :withdrawn_usd_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :donated_usd_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :fee_usd_cents, numericality: { greater_than_or_equal_to: 0 }
end