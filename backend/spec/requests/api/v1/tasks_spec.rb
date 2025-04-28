require 'rails_helper'

RSpec.describe "Api::V1::Tasks", type: :request do
  let(:user) { User.create!(username: 'テスト太郎', email: 'test@example.com', password: 'password123') }
  let(:organization) { Organization.create!(name: 'Team1') }
  let(:workspace) { organization }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  before do
    UserOrganization.create!(user: user, organization: organization)
  end

  describe "GET /api/v1/workspaces/:workspace_id/tasks" do
    it "タスク一覧を取得する" do
      Task.create!(title: 'テストタスク', contents: 'テスト内容', due_date: '2025-04-29', status: '開始前', organization: organization)
      
      get "/api/v1/workspaces/#{workspace.id}/tasks", headers: { Authorization: "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first['title']).to eq('テストタスク')
      expect(JSON.parse(response.body).first['contents']).to eq('テスト内容')
      expect(JSON.parse(response.body).first['due_date']).to eq('2025-04-29')
      expect(JSON.parse(response.body).first['status']).to eq('開始前')
      expect(JSON.parse(response.body).first['organization_id']).to eq(organization.id)
    end
  end
end
