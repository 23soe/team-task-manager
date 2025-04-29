class CreateTaskProgresses < ActiveRecord::Migration[7.0]
  def change
    create_table :task_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :workspace, null: false, foreign_key: true
      t.integer :total_tasks
      t.integer :completed_tasks
      t.decimal :progress_rate

      t.timestamps
    end
  end
end
