require 'rails_helper'

RSpec.describe TaskUser, type: :model do
  describe 'アソシエーション' do
    it 'タスクとユーザーに属している' do
      assoc = TaskUser.reflect_on_association(:task)
      expect(assoc.macro).to eq :belongs_to

      assoc = TaskUser.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end
  end
end
