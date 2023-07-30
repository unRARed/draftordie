require 'rails_helper'

RSpec.describe "Draft", type: :feature do
  include DraftSpecHelper

  let!(:user) { FactoryBot.create(:user) }
  let(:second_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in user
    setup_draft
    @draft = Draft.last
  end

  describe "sends invitations to participants", js: true do
    it "creates pairing records" do
      expect(@draft.pairings.count).to eq(1)
      click_on "Invite Users"
      fill_in "Email", with: second_user.email
      click_on "Send Invite"
      expect(page).to have_content("Invite sent!")

      sign_out user
      sign_in second_user

      visit draft_path(@draft)
      expect(page).to have_content("this draft is restricted")
      fill_in "Access Code", with: @draft.access_code
      click_on "Let me in!"
      expect(@draft.users).not_to include(second_user)

      click_on "Join"
      page.find(".c-notification--notice")
      expect(@draft.reload.users).to include(second_user)
      expect(page).to have_content("You have joined this draft!")
      expect(@draft.pairings.count).to eq(2)
    end
  end
end
