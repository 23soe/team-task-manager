# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_04_29_172718) do
  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_progresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "workspace_id", null: false
    t.integer "total_tasks"
    t.integer "completed_tasks"
    t.decimal "progress_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_task_progresses_on_user_id"
    t.index ["workspace_id"], name: "index_task_progresses_on_workspace_id"
  end

  create_table "task_users", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_users_on_task_id"
    t.index ["user_id"], name: "index_task_users_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "contents"
    t.date "due_date"
    t.string "status"
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.index ["organization_id"], name: "index_tasks_on_organization_id"
  end

  create_table "user_organizations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_user_organizations_on_organization_id"
    t.index ["user_id"], name: "index_user_organizations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "task_progresses", "organizations", column: "workspace_id"
  add_foreign_key "task_progresses", "users"
  add_foreign_key "task_users", "tasks"
  add_foreign_key "task_users", "users"
  add_foreign_key "tasks", "organizations"
  add_foreign_key "user_organizations", "organizations"
  add_foreign_key "user_organizations", "users"
end
