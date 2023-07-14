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

    context "with a new draft" do
      let(:draft) { FactoryBot.create(:draft, user: user) }

      scenario "invites users" do
        another_user = FactoryBot.create(:user)
        visit "/drafts/#{draft.slug}/edit"
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

      context "with users" do
        let(:draft) { FactoryBot.create(:draft, :fast, user: user) }

        before(:each) do
          3.times{ draft.users << FactoryBot.create(:user) }
          draft.generate_board
          sign_in user
          ActionController::Base.allow_forgery_protection = true
        end

        after(:each) do
          ActionController::Base.allow_forgery_protection = false
        end

        scenario "advances selections", js: true do
          visit "/drafts/#{draft.slug}"
          click_on "Begin Draft"
          within(".c-draft__header") do
            expect(page).to have_content(draft.users.first.email)
          end
          expect(page).to have_selector(
            '.c-draft__board__slot--selected', count: 1)
          within(".c-draft__header") do
            expect(page).to have_content(draft.users.second.email)
          end
          expect(page).to have_selector(
            '.c-draft__board__slot--selected', count: 2)
          within(".c-draft__header") do
            expect(page).to have_content(draft.users.third.email)
          end
          expect(page).to have_selector(
            '.c-draft__board__slot--selected', count: 3)
        end
      end

      scenario "generates selections" do
        visit "/drafts/#{draft.slug}/edit"
        click_on "Generate Board"
        expect(page).to have_content("On the clock")

        # 4 users * 2 rounds = 16 selections
        expect(draft.rounds.count).to eq(2)
        expect(draft.selections.count).to eq(8)
      end
    end
  end
end
