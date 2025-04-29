require 'rails_helper'

RSpec.describe "Api::V1::Tasks", type: :request do
  let!(:user) { User.create(username: "テストユーザー", email: "test@example.com", password: "password") }
  let!(:workspace) { Organization.create(name: "テスト組織") }
  let!(:task) {
    Task.create(
      title: "タスクタイトル",
      contents: "タスク内容",
      status: "開始前",
      category: "カテゴリ1",
      due_date: "2025-05-01",
      organization_id: workspace.id,
      users: [user]
    )
  }

  before do
    user.organizations << workspace
    token = JsonWebToken.encode(user_id: user.id)
    @headers = { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/workspaces/:workspace_id/tasks" do
    it "指定したワークスペースのタスク一覧を取得できること" do
      get "/api/v1/workspaces/#{workspace.id}/tasks", headers: @headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first["title"]).to eq(task.title)
      expect(body.first["category"]).to eq(task.category)
      expect(body.first["status"]).to eq(task.status)
    end
  end

  describe "POST /api/v1/workspaces/:workspace_id/tasks" do
    it "新しいタスクを作成できる" do
      post "/api/v1/workspaces/#{workspace.id}/tasks",
      params: {
        title: '新しいタスク',
        contents: '詳細内容',
        status: '開始前',
        category: 'カテゴリ1',
        due_date: '2025-06-01',
        user_ids: [user.id]
      },
      headers: @headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("新しいタスク")
      expect(body["contents"]).to eq("詳細内容")
      expect(body["status"]).to eq("開始前")
      expect(body["category"]).to eq("カテゴリ1")
    end
  end

  describe "PUT /api/v1/tasks/:id" do
    it "既存タスクを更新できる" do
      put "/api/v1/tasks/#{task.id}",
      params: {
        title: '更新されたタスク',
        contents: '更新内容',
        status: '進行中',
        category: 'カテゴリ2',
        due_date: '2025-07-01',
        user_ids: [user.id]
      },
      headers: @headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("更新されたタスク")
      expect(body["status"]).to eq("進行中")
    end
  end

  describe "DELETE /api/v1/tasks/:id" do
    it "タスクを削除できる" do
      delete "/api/v1/tasks/#{task.id}", headers: @headers

      expect(response).to have_http_status(:no_content)
      expect(Task.find_by(id: task.id)).to be_nil
    end
  end
end