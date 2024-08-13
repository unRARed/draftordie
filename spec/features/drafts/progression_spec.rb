require 'rails_helper'

RSpec.describe "Draft Progression", type: :feature do
  include DraftSpecHelper

  let!(:player_pool) do
    FactoryBot.create(:player_pool_with_players)
  end
  let!(:commish) do
    FactoryBot.create(:user,
      email: "commish@draftordie.com")
  end
  let!(:draft) do
    FactoryBot.create(:draft, :fast,
      :complete_commish_only,
      player_pool: player_pool,
      user: commish)
  end

  before(:each) do
    ActionController::Base.allow_forgery_protection = false
    10.times{ FactoryBot.create :player }
  end

  after(:each) do
    ActionController::Base.allow_forgery_protection = true
  end

  context "without interaction" do
    it "works for the commish", js: true do
      sign_in commish

      visit edit_draft_path(draft)
      page.click_on id: "generate-board"
      page.find(
        ".c-notification.c-notification--notice",
        visible: true
      )
      accept_confirm do
        click_on "Start Draft"
      end

      # commish is redirected to the draft dashboard
      # and it's their turn to pick
      page.find("form", visible: true)
      within(".c-draft__pick--current") do
        expect(page).to have_content("Commish's Team")
      end

      # pick time expires
      sleep draft.selection_seconds
      # simulate job running in the background
      ProgressDraftsJob.perform_now
      page.find(".c-draft__pick--missed", visible: true)

      # pick time expires again
      sleep draft.selection_seconds
      # job runs in the background
      ProgressDraftsJob.perform_now
      page.find(".c-draft--ended", visible: true)
    end

    it "works for two users", js: true do
      draft.pairings << FactoryBot.create(:pairing,
        :team_context, user: FactoryBot.create(:user),
        context_value: "Other Team")

      sign_in commish

      visit edit_draft_path(draft)
      page.click_on id: "generate-board"
      page.find(
        ".c-notification.c-notification--notice",
        visible: true
      )
      accept_confirm do
        click_on "Start Draft"
      end

      # commish is redirected to the draft dashboard
      # and it's their turn to pick
      page.find("form", visible: true)
      expect(page).to have_content("Commish's Team")
      expect(page).to have_content("Other Team")

      # it's the commish's pick
      within(".c-draft__pick--current") do
        expect(page).to have_content("Commish's Team")
      end

      # but his pick time expires
      sleep draft.selection_seconds
      # simulate job running in the background
      ProgressDraftsJob.perform_now

      # now it's the other user's pick
      within(".c-draft__pick--current") do
        expect(page).to have_content("Other Team")
      end

      # and then his pick time expires
      sleep draft.selection_seconds
      # simulate job running in the background
      ProgressDraftsJob.perform_now

      # but still his pick
      within(".c-draft__pick--current") do
        expect(page).to have_content("Other Team")
      end

      # and then his pick time expires again
      sleep draft.selection_seconds
      # simulate job running in the background
      ProgressDraftsJob.perform_now

      # so back to the commish
      within(".c-draft__pick--current") do
        expect(page).to have_content("Commish's Team")
      end

      # pick time expires again
      sleep draft.selection_seconds
      # job runs in the background
      ProgressDraftsJob.perform_now

      # Draft is over
      page.find(".c-draft--ended", visible: true)

      #   visit edit_draft_path(draft)
      #   expect(page).
      #     to have_selector(".c-draft__selections", visible: true)
      #   sign_out commish

      #   sign_in user1
      #   visit draft_path(draft)
      #   fill_in "Access Code", with: draft.access_code
      #   click_on "Let me in!"
      #   save_and_open_page
      #   within("main .c-layout__scoped") do
      #     expect(page).not_to have_selector("form")
      #   end
      #   puts draft.remaining_selections.count
      #   sleep 2

      #   puts draft.remaining_selections.count
      #   within(".c-draft__selections-list") do
      #     save_and_open_page
      #     expect(page).to have_selector(
      #       ".c-draft__selection--current", count: 2
      #     )
      #   end
      #   save_and_open_page
      #   within("main .c-layout__scoped") do
      #     page.find("form", visible: true)
      #     click_on "Draft Player"
      #   end
      #   page.find(".c-notification--notice", visible: true)
      #   expect(page).to have_content("Selection updated")
      #   within("main .c-layout__scoped") do
      #     expect(page).not_to have_selector("form")
      #   end
      #   puts ''
    end
  end

  context "with interaction" do
    it "works for two users", js: true do
      other_user = FactoryBot.create(:user)
      draft.pairings << FactoryBot.create(:pairing,
        :team_context, user: other_user,
        context_value: "Other Team")

      using_session(commish) do
        sign_in commish

        visit edit_draft_path(draft)
        page.click_on id: "generate-board"
        page.find(
          ".c-notification.c-notification--notice",
          visible: true
        )
        accept_confirm do
          click_on "Start Draft"
        end

        # commish is redirected to the draft dashboard
        # and it's their turn to pick
        page.find("form", visible: true)
        within(".c-draft__pick--current") do
          expect(page).to have_content("Commish's Team")
        end
        expect(current_path).to eq(draft_path(draft))

        # Users can still navigate away from their selection
        within ".c-layout__header-navigation" do
          click_on "Board"
        end
        expect(page).to have_content("You're on the clock")
        expect(current_path).to eq(board_draft_path(draft))

        # they return to the dashboard
        click_on "Make your selection"
        expect(page).to have_content("Upcoming Selections")

        # Commish selects a player
        within ".c-fuzzy-select" do
          first(".c-fuzzy-select__item").click
          find(".c-fuzzy-select__input").
            native.send_keys(:return)
        end

        page.find(
          ".c-notification.c-notification--notice",
          visible: true
        )

        # now it's the other user's pick
        within(".c-draft__pick--current") do
          expect(page).to have_content("Other Team")
        end
        within ".c-draft" do
          expect(page).to have_no_selector("form")
        end
      end

      using_session(other_user) do
        sign_in other_user

        visit draft_path(draft)
        fill_in "Access Code", with: draft.access_code
        click_on "Let me in"

        page.find(".c-fuzzy-select", visible: true)
        within ".c-draft" do
          expect(page).to have_selector("form")
        end

        # User selects a player
        within ".c-fuzzy-select" do
          first(".c-fuzzy-select__item").click
          find(".c-fuzzy-select__input").
            native.send_keys(:return)
        end

        page.find(
          ".c-notification.c-notification--notice",
          visible: true
        )

        # User selects another player
        within ".c-fuzzy-select" do
          first(".c-fuzzy-select__item").click
          find(".c-fuzzy-select__input").
            native.send_keys(:return)
        end

        page.find(
          ".c-notification.c-notification--notice",
          visible: true
        )
        # Commish turn to pick again
        within ".c-draft" do
          expect(page).to have_no_selector("form")
        end
      end

      using_session(commish) do
        visit draft_path(draft)

        # Commish makes final selection
        within ".c-fuzzy-select" do
          first(".c-fuzzy-select__item").click
          find(".c-fuzzy-select__input").
            native.send_keys(:return)
        end

        page.find(
          ".c-notification.c-notification--notice",
          visible: true
        )
        # Draft is over
        page.find(".c-draft--ended", visible: true)
      end
    end
  end
end
