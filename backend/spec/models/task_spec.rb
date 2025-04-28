require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーションチェック' do
    let(:organization) { Organization.create(name: 'Team1') }

    it '全ての項目が正しく入力されていれば有効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: '2025-04-29',
        status: '開始前',
        organization: organization
      )
      expect(task).to be_valid
    end

    it 'タイトルが空なら無効' do
      task = Task.new(
        title: '',
        contents: 'テスト内容',
        due_date: '2025-04-29',
        status: '開始前',
        organization: organization
      )
      expect(task).not_to be_valid
    end

    it '内容が空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: '',
        due_date: '2025-04-29',
        status: '開始前',
        organization: organization
      )
      expect(task).not_to be_valid
    end

    it '締切日が空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: nil,
        status: '開始前',
        organization: organization
      )
      expect(task).not_to be_valid
    end

    it 'ステータスが空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: '2025-04-29',
        status: '',
        organization: organization
      )
      expect(task).not_to be_valid
    end

    it 'organizationが空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: '2025-04-29',
        status: '開始前',
        organization: nil
      )
      expect(task).not_to be_valid
    end
  end
end
