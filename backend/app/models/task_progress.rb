class TaskProgress < ApplicationRecord
  belongs_to :user
  belongs_to :workspace, class_name: 'Organization', foreign_key: :workspace_id
end
