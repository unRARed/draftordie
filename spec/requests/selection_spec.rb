require 'rails_helper'

RSpec.describe "Selections", type: :request do
  describe "GET /update" do
    it "returns http success" do
      get "/selection/update"
      expect(response).to have_http_status(:success)
    end
  end

end
