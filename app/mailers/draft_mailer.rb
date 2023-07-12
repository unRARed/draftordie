class DraftMailer < ApplicationMailer
  def invite(draft:, email:)
    @draft = draft
    @email = email
    mail(
      to: email,
      subject: "You've been invited to a draft!"
    )
  end
end
