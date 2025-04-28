require 'rails_helper'

RSpec.describe "Api::V1::Workspaces", type: :request do
  describe "GET /api/v1/workspaces" do
    it "ワークスペース一覧を取得する（複数組織）" do
      user = User.create!(username: "テスト太郎", email: "test@example.com", password: "password123")

      organization1 = Organization.create!(name: "Team1")
      organization2 = Organization.create!(name: "Team2")
      organization3 = Organization.create!(name: "Team3")

      user.organizations << [organization1, organization2, organization3]

      token = JsonWebToken.encode(user_id: user.id)

      get "/api/v1/workspaces", headers: { Authorization: "Bearer #{token}" }

      expect(response).to have_http_status(:ok)

      parsed_body = JSON.parse(response.body)
      workspaces = parsed_body['workspace']

      expect(workspaces.size).to eq(3)
      expect(workspaces.map { |w| w['name'] }).to contain_exactly('Team1', 'Team2', 'Team3')
    end
  end
end
