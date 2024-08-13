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
    select player_pool.name, from: "Player Pool"
    fill_in "Name", with: "My Draft"
    fill_in "Number of Rounds", with: 4
    fill_in "Time per Selection", with: 1
    fill_in "Number of Participants", with: 4
    click_on "Create Draft"

    draft = Draft.last
    expect(page).to have_content("Draft created successfully")

    click_on "Invite"
    fill_in "Email", with: "invited@example.com"
    click_on "Send Invite"
    expect(page).to have_content("Invite sent!")
    sign_out user

    using_session :invited do
      visit draft_path(draft, access_code: draft.access_code)
      # access code is already filled in
      expect(page).
        to have_field('Access Code', with: draft.access_code)
      click_on "Let me in!"
      expect(page).to have_content("Draft Board has not been setup yet.")
    end
  end
end
