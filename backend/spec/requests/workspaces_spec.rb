require 'rails_helper'

RSpec.describe "Workspaces", type: :request do
  describe "GET /workspaces" do
    let!(:user) { User.create!(
      username: 'テスト太郎',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )}
    let!(:organization1) { Organization.create!(name: "Team1")}
    let!(:organization2) { Organization.create!(name: "Team2")}

    before do
      # ユーザーを組織に関連付ける
      user.organizations << organization1
      user.organizations << organization2
    end

    let(:token) do
      post '/login', params: { email: 'test@example.com', password: 'password123' }
      JSON.parse(response.body)['token']
    end
    
    context "正常系（認証トークンが有効な場合）" do
      it "所属しているワークスペース一覧を取得できる" do
        get '/workspaces', headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)

        expect(body['workspace'].size).to eq(2)
        expect(body['workspace'].map { |w| w['name'] }).to include("Team1", "Team2")
      end
    end

    context "異常系（認証トークンが無効な場合）" do
      it "401エラーを返す" do
        get '/workspaces'

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include("Invalid token")
      end
    end
  end
end
