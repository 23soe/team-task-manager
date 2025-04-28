require 'rails_helper'

RSpec.describe RegistrationService do
    describe '#call' do
        let(:user_params) do
            {
                username: 'テスト太郎',
                email: 'test@example.com',
                password: 'password123',
                password_confirmation: 'password123'
            }
        end
        let(:organization_names) { ["Team A", "Team B"] }

        context '正常系（ユーザーと組織を作成できる）' do
            it 'ユーザーと組織を作成し、成功を返す' do
                service = RegistrationService.new(user_params, organization_names)
                result = service.call

                expect(result[:success]).to be true
                expect(User.exists?(email: 'test@example.com')).to be true
                expect(Organization.where(name: ["Team A", "Team B"]).count).to eq(2)
                user = User.find_by(email: 'test@example.com')
                expect(user.organizations.map(&:name)).to match_array(["Team A", "Team B"])
            end
        end
        
        context '異常系（ユーザーのバリデーションエラー）' do
            it 'ユーザーのバリデーションエラーで失敗を返す' do
                invalid_user_params = user_params.merge(email: '')
                service = RegistrationService.new(invalid_user_params, organization_names)
                result = service.call

                expect(result[:success]).to be false
                expect(result[:errors]).not_to be_empty
            end
        end
    end
end