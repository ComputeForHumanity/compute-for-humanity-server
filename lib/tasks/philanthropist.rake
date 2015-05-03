#! /usr/bin/env ruby

namespace :philanthropist do
  desc "Exchange BTC for USD via Coinbase."
  task(exchange: :environment) { Philanthropist.new(action: :exchange) }

  desc "Confirm that exchange completed successfully."
  task(confirm: :environment) { Philanthropist.new(action: :confirm) }

  desc "Donate USD to charity."
  task(donate: :environment) { Philanthropist.new(action: :donate) }
end

class Philanthropist
  extend Memoist

  # Don't sell BTC in amounts of less than this amount.
  # 500000 Satoshis = 0.005 BTC
  MINIMUM_EXCHANGE_SATOSHIS = ENV["MINIMUM_EXCHANGE_SATOSHIS"] || 500000

  # Always leave at least this much BTC in wallet when selling.
  # 1000000 Satoshis = 0.01 BTC
  MINIMUM_ACCOUNT_SATOSHIS = ENV["MINIMUM_ACCOUNT_SATOSHIS"] || 1000000

  # The number of minutes after a sell's payout time at which we can mark the
  # sell as confirmed.
  # 4320 minutes = 3 days
  CONFIRMATION_CUSHION_MINUTES = ENV["CONFIRMATION_CUSHION_MINUTES"] || 4320

  # Always leave at least this much USD in account when donating.
  # 100 cents = $1.00
  MINIMUM_ACCOUNT_CENTS = ENV["MINIMUM_ACCOUNT_CENTS"] || 100

  def initialize(action:)
    @action = action

    if [:exchange, :confirm].include? action
      send("#{action}!")
    else
      raise "Invalid action #{action}!"
    end
  end

  private

  def coinbase
    Coinbase::Client.new(
      ENV["COINBASE_API_KEY"],
      ENV["COINBASE_API_SECRET"]
    )
  end
  memoize :coinbase

  def exchange!
    balance = coinbase.balance

    minimum_account_btc = Money.new(MINIMUM_ACCOUNT_SATOSHIS, "BTC")
    minimum_exchange_btc = Money.new(MINIMUM_EXCHANGE_SATOSHIS, "BTC")

    if balance > minimum_account_btc + minimum_exchange_btc
      amount_to_trade_str = (balance - minimum_account_btc).to_s
      Rails.logger.info "Exchanging #{amount_to_trade_str} BTC for USD"

      # coinbase.sell! immediately decrements BTC balance, and money is sent
      # directly to bank account.
      safe do
        begin
          sell_info = coinbase.sell!(amount_to_trade_str)

          if sell_info.success
            transfer = sell_info.transfer

            Exchange.create!(
              created_at: transfer.created_at,
              transaction_id: transfer.transaction_id,
              initial_btc: transfer.btc,
              exchanged_usd: transfer.total,
              fee_usd: transfer.subtotal - transfer.total
            )
          end
        # Occurs when the amount to sell is too low for Coinbase's limits.
      rescue Coinbase::Client::Error => e
          Rails.logger.info "ERROR: #{e.message}"
        end
      end
    end
  end

  def confirm!
    Exchange.
      where(complete: false).
      where("payout_date < ?", Time.now - CONFIRMATION_CUSHION_MINUTES.minutes).
      each do |exchange|

      Rails.logger.info "Checking exchange #{exchange.id} for confirmation"
      txn = coinbase.transaction(exchange.transaction_id)

      if txn.transaction.status == "complete"
        Rails.logger.info "Confirming exchange #{exchange.id}"
        safe { exchange.update!(complete: true) }
      end
    end
  end

  def donate!
  end

  def safe
    if ENV["TESTING"] == "true"
      Rails.logger.info "** Skipping #{@action} while in testing mode. **"
    elsif ENV[@action.to_s.upcase] != "true"
      Rails.logger.info "** Skipping #{@action}. **"
    else
      yield
    end
  end
end
