require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
    describe 'POST /signup' do
        let(:valid_params)do
        {
            user: {
                username: 'テスト太郎',
                email: 'test@example.com',
                password: 'password123',
                password_confirmation: 'password123'
            },
            organization_names: ["Team A", "Team B"]
        }
        end

        context '正常系（ユーザーと組織を正常に作成できる場合）' do
            it 'ユーザー登録に成功し、201を返す' do
                expect {
                    post '/signup', params: valid_params
            }.to change(User, :count).by(1)
            .and change(Organization, :count).by(2)
            .and change(UserOrganization, :count).by(2)

            expect(response).to have_http_status(:created)
            body = JSON.parse(response.body)
            expect(body['user']['email']).to eq('test@example.com')
            end
        end
        
        context '異常系（バリデーションエラーの場合）' do
            it 'ユーザー登録に失敗し、422を返す' do
                invalid_params = valid_params.deep_merge(user: { email: '' })

                expect { 
                    post '/signup', params: invalid_params
                }.to_not change(User, :count)

                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).not_to be_empty
            end
        end
    end
end