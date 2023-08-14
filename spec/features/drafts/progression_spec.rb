require 'rails_helper'

RSpec.describe "Draft Progression", type: :feature do
  include DraftSpecHelper

  let(:user) { FactoryBot.create(:user) }
  let(:draft) { FactoryBot.create(:draft, user: user) }

  before(:each) do
    ActionController::Base.allow_forgery_protection = true
  end

  after(:each) do
    ActionController::Base.allow_forgery_protection = false
  end

  context "as the commish" do
    it :succeeds, js: true do
      create_and_start_draft(user)

      fill_in "Name", with: "Russell Wilson"
      select "QB", from: "Position"
      click_on "Draft Player"

      pending "need to figure out how to test this"
      raise

      expect(page).to have_content("Selection made")
    end
  end

  context "as a spectator" do
    let(:second_user) { FactoryBot.create(:user) }

    it :succeeds, js: true do
      create_and_start_draft(user)
      draft = Draft.last
      visit board_draft_path(draft)
      sign_out user

      sign_in second_user
      visit board_draft_path(draft)

      fill_in "Access Code", with: draft.access_code
      click_button "Let me in"
      # page.find('.c-draft__board', visible: true)

      click_on "Join"
      expect(page).to have_content("Team Name")
      fill_in "Team Name", with: "My Team"
      click_on "Join Draft"

      visit board_draft_path(draft)
      expect(page).
        to have_selector('.c-draft__board__slot--current')
      expect(page).
        to have_no_selector('.c-draft__board__slot--selected')

      pending "need to figure out how to test this"
      raise

      perform_enqueued_jobs { ProgressDraftsJob.perform_later }

      visit board_draft_path(draft)

      page.find('.c-draft__board__slot--selected', visible: true)
      puts "got here"


      # # job runs every 1 second checking for drafts
      # # to advance and progresses them
      # expect(page).to have_selector(
      #   '.c-draft__board__slot--selected', count: 1)

      # # job runs every 1 second checking for drafts
      # # to advance and progresses them
      # ProgressDraftsJob.perform_now
      # visit "/drafts/#{draft.slug}"

      # expect(page).to have_selector(
      #   '.c-draft__board__slot--selected', count: 2)

      # # job runs every 1 second checking for drafts
      # # to advance and progresses them
      # ProgressDraftsJob.perform_now
      # expect(page).to have_selector(
      #   '.c-draft__board__slot--selected', count: 3)

      # expect(draft.selections.count).to eq(16)
      # expect(draft.upcoming_selections.count).to eq(13)

      # selections = page.all(
      #   class: 'c-draft__board__slot--selected'
      # ).each_with_index do |cell, cell_index|
      #   expect(cell[:id]).
      #     to eq("pick_number_#{cell_index + 1}")
      # end
    end
  end
end
