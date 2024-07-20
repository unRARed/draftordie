# Preview all emails at http://localhost:3000/rails/mailers/draft
class DraftPreview < ActionMailer::Preview
  def invite
    DraftMailer.
      with(email: 'email@example.com', draft: Draft.first).
      invite
  end
end
