class RemoveWorkspaceFkFromTaskProgresses < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :task_progresses, :workspaces
  end
end
