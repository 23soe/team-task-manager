require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:organization) { Organization.create!(name: "テスト組織") }

  describe 'バリデーションチェック' do
    it '全ての項目が正しく入力されていれば有効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: Date.today,
        category: 'カテゴリ1',
        status: '開始前',
        organization_id: organization.id
      )
      expect(task).to be_valid
    end

    it 'タイトルが空なら無効' do
      task = Task.new(
        title: '',
        contents: 'テスト内容',
        due_date: Date.today,
        category: 'カテゴリ1',
        status: '開始前',
        organization_id: organization.id
      )
      expect(task).not_to be_valid
    end

    it '内容が空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: '',
        due_date: Date.today,
        category: 'カテゴリ1',
        status: '開始前',
        organization_id: organization.id
      )
      expect(task).not_to be_valid
    end

    it '締切日が空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: nil,
        category: 'カテゴリ1',
        status: '開始前',
        organization_id: organization.id
      )
      expect(task).not_to be_valid
    end

    it 'カテゴリが空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: Date.today,
        category: '',
        status: '開始前',
        organization_id: organization.id
      )
      expect(task).not_to be_valid
    end

    it 'ステータスが空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: Date.today,
        category: 'カテゴリ1',
        status: '',
        organization_id: organization.id
      )
      expect(task).not_to be_valid
    end

    it 'organizationが空なら無効' do
      task = Task.new(
        title: 'テストタスク',
        contents: 'テスト内容',
        due_date: Date.today,
        category: 'カテゴリ1',
        status: '開始前',
        organization: nil
      )
      expect(task).not_to be_valid
    end
  end
end
