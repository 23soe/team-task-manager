require 'rails_helper'

RSpec.describe "Sessions", type: :request do
    describe "POST /login" do
        let!(:user) { User.create!(
            username: 'テスト太郎',
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123'
        )}

        context "正常系（正しいメールアドレスとパスワードを送信した場合）" do
            it "ログインに成功し、トークンを取得できる" do
                post '/login', params: { email: 'test@example.com', password: 'password123' }

                expect(response).to have_http_status(:ok)
                body = JSON.parse(response.body)

                expect(body['token']).to be_present
                expect(body['user']['email']).to eq('test@example.com')
            end
        end

        context "異常系（無効なメールアドレスまたはパスワードを送信した場合）" do
            it "ログインに失敗し、401を返す" do
                post '/login', params: { email: 'test@example.com', password: 'wrongpassword' }

                expect(response).to have_http_status(:unauthorized)
                expect(JSON.parse(response.body)['errors']).to include("Invalid email or password")
            end
        end

        context "異常系（メールアドレスが存在しない場合）" do
            it "ログインに失敗し、401を返す" do
                post '/login', params: { email: 'notfound@example.com', password: 'password123' }

                expect(response).to have_http_status(:unauthorized)
                expect(JSON.parse(response.body)['errors']).to include("Invalid email or password")
            end
        end
    end

    describe "GET /me" do
        let!(:user) { User.create!(
            username: 'テスト太郎',
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123'
        )}
        let(:token) do
            post '/login', params: { email: 'test@example.com', password: 'password123' }
            JSON.parse(response.body)['token']
        end

        context "正常系（認証トークンが有効な場合）" do
            it "ユーザー情報を取得できる" do
                # トークンを使って /me にアクセス
                get '/me', headers: { "Authorization" => "Bearer #{token}" }

                expect(response).to have_http_status(:ok)
                body = JSON.parse(response.body)

                expect(body['user']['email']).to eq('test@example.com')
                expect(body['user']['username']).to eq('テスト太郎')
            end
        end
        context "異常系（認証トークンが無効な場合）" do
            it "401を返す" do
                get '/me'

                expect(response).to have_http_status(:unauthorized)
                expect(JSON.parse(response.body)['errors']).to include("Invalid token")
            end
        end
    end
end