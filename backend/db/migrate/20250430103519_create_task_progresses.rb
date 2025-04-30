class CreateTaskProgresses < ActiveRecord::Migration[7.0]
  def change
    create_table :task_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :workspace_id
      t.integer :total_tasks
      t.integer :completed_tasks
      t.decimal :progress_rate

      t.timestamps
    end

    add_foreign_key :task_progresses, :organizations, column: :workspace_id
  end
end
