class AddOrganizationFkToTaskProgresses < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :task_progresses, :organizations, column: :workspace_id
  end
end
