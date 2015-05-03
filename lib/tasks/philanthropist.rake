#! /usr/bin/env ruby

namespace :philanthropist do
  desc "Exchange BTC for USD via Coinbase."
  task(exchange: :environment) { Philanthropist.new(action: :exchange) }

  desc "Donate USD to charity."
  task(donate: :environment) { Philanthropist.new(action: :donate) }
end

class Philanthropist
  extend Memoist

  # Don't trade less than this amount.
  MINIMUM_EXCHANGE_BTC = ENV["MINIMUM_EXCHANGE_BTC"] || 0.00005

  # Always leave at least this much in wallet.
  MINIMUM_ACCOUNT_BTC = ENV["MINIMUM_ACCOUNT_BTC"] || 0.003

  # Always leave at least this much in account.
  MINIMUM_ACCOUNT_USD = ENV["MINIMUM_ACCOUNT_USD"] || 0.0

  def initialize(action:)
    @action = action

    if [:exchange, :withdraw].include? action
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

    if balance.to_d > MINIMUM_ACCOUNT_BTC + MINIMUM_EXCHANGE_BTC
      amount_to_trade = (balance.to_d - MINIMUM_ACCOUNT_BTC).to_digits
      Rails.logger.info "Exchanging #{amount_to_trade} BTC for USD"

      # coinbase.sell! immediately decrements BTC balance, and money is sent
      # directly to bank account.
      safe do
        sell_info = coinbase.sell!(amount_to_trade)

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
      end
    end
  end

  def donate!
  end

  def btc_balance
    @coinbase.balance.to_d
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
