class User < ApplicationRecord
    has_secure_password
  
    has_many :user_organizations, dependent: :destroy
    has_many :organizations, through: :user_organizations
  
    has_many :task_users, dependent: :destroy 
    has_many :tasks, through: :task_users
  
    validates :username, presence: true
    validates :email, presence: true, uniqueness: true
  end
  