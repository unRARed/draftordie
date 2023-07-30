# frozen_string_literal: true

require "rails_helper"

module DraftSpecHelper
  def setup_draft
    visit "/drafts/new"
    fill_in "Name", with: "My Draft"
    fill_in "Number of Rounds", with: 4
    fill_in "Time per Selection", with: 1
    fill_in "Number of Participants", with: 4
    click_on "Create Draft"
    expect(page).to have_content("Draft created successfully")
  end

  def create_and_start_draft(user)
    sign_in user
    setup_draft
    draft = Draft.last
    3.times{ draft.users << FactoryBot.create(:user) }
    draft.generate_board

    visit "/drafts/#{draft.slug}/edit"
    accept_confirm do
      click_on "Start Draft"
    end
  end
end
