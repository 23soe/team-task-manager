require 'rails_helper'

RSpec.describe User, type: :model do
    let(:username) { 'テスト太郎' }
    let(:email) { 'test@example.com' }
    let(:password) { 'password123' }
    let(:user) { User.new(username: username, email: email, password: password, password_confirmation: password) }
  
    describe 'バリデーションチェック' do
        context '有効な場合' do
            it 'username, email, passwordが正しく入力されていれば有効' do
            expect(user).to be_valid
            end
        end
    
        context '無効な場合' do
            context 'usernameが空の場合' do
                let(:username) { '' }
        
                it '無効である' do
                    expect(user).not_to be_valid
                    expect(user.errors[:username]).to include("を入力してください")
                end
            end
    
            context 'emailが空の場合' do
                let(:email) { '' }
        
                it '無効である' do
                    expect(user).not_to be_valid
                    expect(user.errors[:email]).to include("を入力してください")
                end
            end
        
            context 'passwordが空の場合' do
                let(:password) { '' }
        
                it '無効である' do
                    expect(user).not_to be_valid
                    expect(user.errors[:password]).to include("を入力してください")
                end
            end
        end
    end
end