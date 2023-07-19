require 'rails_helper'

RSpec.describe "Draft", type: :feature do
  let(:user) { FactoryBot.create(:user) }

  describe "admin" do
    scenario "sets up a draft" do
      sign_in user
      draft = setup_draft
      expect(Draft.last.reload.users).to include(user)
    end

    context "with a new draft" do
      let(:draft) { FactoryBot.create(:draft, user: user) }

      scenario "invites users" do
        another_user = FactoryBot.create(:user)
        draft.generate_board
        sign_in user
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
        before(:each) do
          ActionController::Base.allow_forgery_protection = true
          sign_in user
          setup_draft
          @draft = Draft.last
          3.times{ @draft.users << FactoryBot.create(:user) }
          @draft.generate_board
          visit "/drafts/#{@draft.slug}"
          click_on "Begin Draft"
        end

        after(:each) do
          ActionController::Base.allow_forgery_protection = false
        end

        scenario "advances selections automatically", js: true do
          expect(page).to have_content("On the clock")
          # 4 rounds, 3 for users, 1 for the commish
          expect(@draft.rounds.count).to eq(4)
          # 4 picks each of the 3 users and commish (4*4 = 16)
          expect(@draft.selections.count).to eq(16)
          expect(@draft.upcoming_selections.count).to eq(16)

          within(".c-draft__header") do
            expect(page).to have_content(@draft.users.first.email)
          end
          expect(page).to have_selector(
            '.c-draft__board__slot--selected', count: 1)
          within(".c-draft__header") do
            expect(page).to have_content(@draft.users.second.email)
          end
          expect(page).to have_selector(
            '.c-draft__board__slot--selected', count: 2)
          within(".c-draft__header") do
            expect(page).to have_content(@draft.users.third.email)
          end
          expect(page).to have_selector(
            '.c-draft__board__slot--selected', count: 3)

          expect(@draft.selections.count).to eq(16)
          expect(@draft.upcoming_selections.count).to eq(13)

          selections = page.all(
            class: 'c-draft__board__slot--selected'
          ).each_with_index do |cell, cell_index|
            expect(cell[:id]).
              to eq("pick_number_#{cell_index + 1}")
          end
        end
      end
    end
  end

  def setup_draft
    visit "/drafts/new"
    fill_in "Name", with: "My Draft"
    fill_in "Number of Rounds", with: 4
    fill_in "Time per Selection", with: 1
    fill_in "Number of Players", with: 4
    click_on "Create Draft"
    expect(page).to have_content("Draft created successfully")
  end
end
