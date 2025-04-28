class Task < ApplicationRecord
  belongs_to :organization
  has_many :task_users, dependent: :destroy
  has_many :users, through: :task_users

  validates :title, presence: true
  validates :contents, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :organization_id, presence: true
end
