class Banker
  # @return [Money] how much is available to be donated
  def self.available_for_donation
    exchanged_cents = Exchange.where(complete: true).sum(:exchanged_usd_cents)
    donated_cents = Donation.sum(:initial_usd_cents)

    Money.new(exchanged_cents - donated_cents, "USD")
  end

  def self.total_donated_s
    total_cents = Donation.completed.sum(:initial_usd_cents)

    "$#{Money.new(total_cents, "USD").to_s}"
  end
end
