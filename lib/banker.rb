class Banker
  # This is NiceHash's lowest payout threshold.
  # See: https://www.nicehash.com/?p=faq#faqs6
  PAYOUT_BALANCE = Money.new(10000, "BTC").freeze # 0.0001 BTC

  # @param unpaid_balance [Money] the current unpaid NiceHash balance
  # @return [Integer] the percentage of the way toward a NiceHash payout we are
  # Note: This method caps its output at 100 (percent) because NiceHash pays out
  # on a schedule (see link above) and so we could be over the threshold and not
  # yet paid out.
  def self.payout_completion_percentage(unpaid_balance:)
    [(unpaid_balance / PAYOUT_BALANCE * 100).round, 100].min
  end

  # @return [Money] how much is available to be donated
  def self.available_for_donation
    exchanged_cents = Exchange.where(complete: true).sum(:exchanged_usd_cents)
    donated_cents = Donation.sum(:initial_usd_cents)

    Money.new(exchanged_cents - donated_cents, "USD")
  end

  def self.total_donated_s
    total_cents = Donation.completed.sum(:initial_usd_cents)

    "$#{Money.new(total_cents, 'USD')}"
  end
end
