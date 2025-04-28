class Organization < ApplicationRecord
    has_many :user_organizations
    has_many :users, through: :user_organizations

    has_many :tasks
end
