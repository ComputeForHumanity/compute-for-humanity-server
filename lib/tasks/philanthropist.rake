#! /usr/bin/env ruby

namespace :philanthropist do
  desc "Confirm that donation completed successfully."
  task(confirm: :environment) { Philanthropist.new(action: :confirm) }

  desc "Donate USD to charity."
  task(donate: :environment) { Philanthropist.new(action: :donate) }
end

class Philanthropist
  extend Memoist

  # Casts an environment variable to an int, using a fallback if not set.
  # @param name [String] the name of the environment variable
  # @param default [Integer] the fallback value to use if env var isn't set
  # @return [Integer] the integer value of the env var, or default if not set
  def self.env_to_i(name, default)
    ENV[name] ? ENV[name].to_i : default
  end

  # Don't sell BTC in amounts of less than this amount.
  # 500000 Satoshis = 0.005 BTC
  MINIMUM_EXCHANGE_SATOSHIS = env_to_i("MINIMUM_EXCHANGE_SATOSHIS", 500000)

  # Always leave at least this much BTC in wallet when selling.
  # 1000000 Satoshis = 0.01 BTC
  MINIMUM_ACCOUNT_SATOSHIS = env_to_i("MINIMUM_ACCOUNT_SATOSHIS", 1000000)

  # The number of minutes after a sell's payout time at which we can mark the
  # sell as confirmed.
  # 4320 minutes = 3 days
  CONFIRMATION_CUSHION_MINUTES = env_to_i("CONFIRMATION_CUSHION_MINUTES", 4320)

  # Always leave at least this much USD in account when donating.
  # 0 cents = $0.00
  MINIMUM_ACCOUNT_CENTS = env_to_i("MINIMUM_ACCOUNT_CENTS", 0)

  # Don't donate more than $10 at a time, to avoid Dwolla's transaction fees.
  MAXIMUM_DONATION_CENTS = env_to_i("MAXIMUM_DONATION_CENTS", 1000)

  # Initializes the Philanthropist and executes the given action.
  # @param action [Symbol] the action to take
  # @raise if action is invalid
  def initialize(action:)
    @action = action

    if [:confirm, :donate].include? action
      send("#{action}!")
    else
      raise "Invalid action #{action}!"
    end
  end

  private

  # Confirm donations so we can mark them in our database as fully processed.
  def confirm!
    Dwolla::token = DwollaSecret.oauth_token!
    Donation.pending.each do |donation|
      Rails.logger.info "Checking donation #{donation.id} for confirmation"
      txn = Dwolla::Transactions.get(donation.transaction_id)

      if txn["Status"] != donation.status
        Rails.logger.info "Updating donation #{donation.id}: #{txn['Status']}"
        safe { donation.update!(status: txn["Status"]) }
      end
    end
  end

  # Donate money through Dwolla to a random charity from our list.
  def donate!
    Dwolla::token = DwollaSecret.oauth_token!

    sources = Dwolla::FundingSources.get
    source_id = sources.find { |src| src["ProcessingType"] == "ACH" }["Id"]

    possible_donation = Banker.available_for_donation -
                        Money.new(MINIMUM_ACCOUNT_CENTS, "USD")
    maximum_donation = Money.new(MAXIMUM_DONATION_CENTS, "USD")
    amount_to_donate = [possible_donation, maximum_donation].min

    if amount_to_donate > Money.new(1, "USD")
      Rails.logger.info "Donating $#{amount_to_donate} to #{charity.name}"

      safe do
        # We save the donation to the database before making the API call for it
        # to prevent cases in which we've made the API call but the program
        # crashes before the save can be made and we end up double-spending the
        # same money.
        donation = Donation.create!(
          charity_name: charity.name,
          initial_usd: amount_to_donate
        )

        transaction_id = Dwolla::Transactions.send(
          destinationId: charity.dwolla_id,
          amount: amount_to_donate.to_s,
          pin: DwollaSecret.pin,
          fundsSource: source_id,
          notes: "This is an automated donation powered by Compute for "\
                 "Humanity. Learn more at computeforhumanity.org!"
        )

        details = Dwolla::Transactions.get(transaction_id)

        # We keep the Dwolla transactions below the amount that charges fees,
        # but just in case something goes awry this code will capture any fees
        # Dwolla charges.
        fee_usd_cents = (details["Fees"] || []).map do |fee|
          fee["Amount"].to_f
        end.sum * 100
        fee_usd = Money.new(fee_usd_cents, "USD")

        donation.update!(
          transaction_id: transaction_id,
          status: details["Status"],
          fee_usd: fee_usd,
          donated_usd: amount_to_donate - fee_usd
        )
      end
    end

    puts "Done"
  end

  # @return [Charity] a random charity to donate to, of the form:
  # { name: "...", dwolla_id: "..." }
  def charity
    Charity::LIST[SecureRandom.random_number(Charity::LIST.size)]
  end
  memoize :charity

  # Expects a block to be passed, and only yields to that block if both of the
  # following are true:
  # - There isn't a TESTING environment variable set to `true`.
  # - There is an environment variable named after the current action
  #   (e.g. DONATE) set to `true`.
  # This allows instant per-action and global enabling/disabling, for
  # development safety and emergency shutoff.
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
