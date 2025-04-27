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
            }
        }
        end

        let(:invalid_params) do
            {
                user: {
                    username: '',
                    email: '',
                    password: '',
                    password_confirmation: ''
                }
            }
        end

        context '有効なパラメータの場合' do
            it 'ユーザー登録に成功し、201を返す' do
                post '/signup', params: valid_params
                expect(response).to have_http_status(:created)
                expect(JSON.parse(response.body)['user']['username']).to eq('テスト太郎')
            end
        end
        
        context '無効なパラメータの場合' do
            it 'ユーザー登録に失敗し、422を返す' do
                post '/signup', params: invalid_params
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).not_to be_empty
            end
        end
    end
end