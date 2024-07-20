class DraftMailer < ApplicationMailer
  def invite
    @draft = params[:draft]
    @email = params[:email]
    mail(
      to: @email,
      subject: "You've been invited to a draft!"
    )
  end
end
