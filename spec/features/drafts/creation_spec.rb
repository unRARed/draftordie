require 'rails_helper'

RSpec.describe "Draft Creation", type: :feature do
  include DraftSpecHelper

  let!(:player_pool) { FactoryBot.create(:player_pool) }
  let!(:user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in user
  end

  it :succeeds, js: true do
    visit "/drafts/new"
    fill_in "Name", with: "My Draft"
    fill_in "Number of Rounds", with: 4
    fill_in "Time per Selection", with: 1
    fill_in "Number of Participants", with: 4
    click_on "Create Draft"

    draft = Draft.last
    expect(page).to have_content("Draft created successfully")

    # Add the commish to the draft
    click_on "Join"
    fill_in "Team Name", with: "Commish FTW"
    click_button "Join"
    page.find(".c-notification--notice")
    expect(page).to have_content("You have joined this draft!")
    expect(draft.pairings.count).to eq(1)

    # assume we've invited 3 other participants
    3.times do
      draft.pairings << FactoryBot.create(:pairing, :team_context,
        pairable: draft,
        user: FactoryBot.create(:user)
      )
    end

    click_on "Setup"
    click_on "Generate Board"
    page.find(".c-notification--notice")
    expect(page).to have_content("Draft board generated!")

    # 4 rounds, 3 for users, 1 for the commish
    expect(draft.rounds.count).to eq(4)

    # 4 picks each of the 3 users and commish (4*4 = 16)
    expect(draft.selections.count).to eq(16)
    expect(draft.upcoming_selections.count).to eq(16)
  end
end
