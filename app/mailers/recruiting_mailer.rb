class RecruitingMailer < ApplicationMailer
  def invite(address:, referral:)
    # Basic sanitation.
    @referral = referral if referral =~ /\A[A-z\d\-]+\z/

    mail(to: address, subject: "Someone's invited you!")
  end
end
