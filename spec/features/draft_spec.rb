require 'rails_helper'

RSpec.describe "Draft", type: :feature do
  let(:user) { FactoryBot.create(:user) }

  describe "admin" do
    scenario "sets up a draft" do
      sign_in user
      visit "/"
      click_on "Start a Draft"
      fill_in "Name", with: "My Draft"
      fill_in "Number of Rounds", with: 4
      fill_in "Time per Selection", with: 5
      fill_in "Number of Players", with: 4
      click_on "Create Draft"
      expect(page).to have_content("Draft created successfully")
      expect(draft.users).to include(user)
    end

    context "with a draft" do
      let!(:draft) { FactoryBot.create(:draft, user: user) }

      before(:each) do
        4.times{ draft.users << FactoryBot.create(:user) }
        sign_in user
      end

      scenario "invites users" do
        another_user = FactoryBot.create(:user)
        visit "/drafts/#{draft.slug}/edit"
        save_and_open_page
        click_on "Invite Users"
        fill_in "Email", with: another_user.email
        click_on "Send Invite"
        expect(page).to have_content("Invite sent!")

        sign_out user
        sign_in another_user

        visit draft_path(draft)
        expect(page).to have_content("this draft is restricted")
        fill_in "Access Code", with: draft.access_code
        click_on "Let me in!"
        expect(page).to have_content("You have joined the draft!")
      end

      scenario "generates selections" do
        visit "/drafts/#{draft.slug}/edit"
        click_on "Generate Board"
        expect(page).to have_content("On the clock")

        # 4 users * 2 rounds = 16 selections
        expect(draft.rounds.count).to eq(2)
        expect(draft.selections.count).to eq(8)
      end
      scenario "starts the draft"
    end
  end
end
