require 'rails_helper'

RSpec.describe "Draft", type: :feature do
  let!(:user) { FactoryBot.create(:user) }
  let!(:draft) { FactoryBot.create(:draft, user: user) }
  let(:second_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in user
    draft = setup_draft
  end

  context "inviting users", js: true do
    it "creates pairing records" do
      expect(draft.pairings.count).to eq(0)
      click_on "Invite Users"
      fill_in "Email", with: second_user.email
      click_on "Send Invite"
      expect(page).to have_content("Invite sent!")

      sign_out user
      sign_in second_user

      visit draft_path(draft)
      expect(page).to have_content("this draft is restricted")
      fill_in "Access Code", with: draft.access_code
      click_on "Let me in!"
      expect(draft.users).not_to include(second_user)

      click_on "Join"
      page.find(".c-notification--notice")
      expect(draft.reload.users).to include(second_user)
      expect(page).to have_content("You have joined this draft!")
      expect(draft.pairings.count).to eq(1)
    end
  end

private

  def setup_draft
    visit "/drafts/new"
    fill_in "Name", with: "My Draft"
    fill_in "Number of Rounds", with: 4
    fill_in "Time per Selection", with: 1
    fill_in "Number of Participants", with: 4
    click_on "Create Draft"
    expect(page).to have_content("Draft created successfully")
  end
end
