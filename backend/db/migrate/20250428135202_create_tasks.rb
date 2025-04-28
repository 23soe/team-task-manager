class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :contents
      t.date :due_date
      t.string :status
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
