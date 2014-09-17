# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140916175631) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"
  enable_extension "pg_trgm"

  create_table "access_requests", force: true do |t|
    t.integer  "assessment_id"
    t.integer  "user_id"
    t.string   "roles",         default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  create_table "answers", force: true do |t|
    t.integer  "value"
    t.text     "content"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assessments", force: true do |t|
    t.string   "name"
    t.datetime "due_date"
    t.datetime "meeting_date"
    t.integer  "user_id"
    t.integer  "rubric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "district_id"
    t.text     "message"
    t.datetime "assigned_at"
    t.string   "mandrill_id"
    t.text     "mandrill_html"
    t.text     "report_takeaway"
  end

  create_table "assessments_facilitators", force: true do |t|
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "assessments_network_partners", force: true do |t|
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "assessments_viewers", force: true do |t|
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "axes", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "axis_id"
  end

  create_table "categories_organizations", id: false, force: true do |t|
    t.integer "category_id",     null: false
    t.integer "organization_id", null: false
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dismissed_popovers", force: true do |t|
    t.integer  "user_id"
    t.string   "popover_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "district_messages", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "sender_name"
    t.string   "sender_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", force: true do |t|
    t.string   "lea_id"
    t.string   "lea_type"
    t.string   "fipst"
    t.string   "stid"
    t.string   "name"
    t.string   "county_name"
    t.string   "county_number"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "zip4"
    t.string   "phone"
    t.string   "mail_street"
    t.string   "mail_city"
    t.string   "mail_state"
    t.string   "mail_zip"
    t.string   "mail_zip4"
    t.string   "longitude"
    t.string   "latitude"
    t.string   "lowest_grade"
    t.string   "highest_grade"
    t.string   "union"
    t.string   "csa"
    t.string   "cbsa"
    t.string   "metmic"
    t.string   "ulocal"
    t.string   "cdcode"
    t.string   "bound"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts_users", force: true do |t|
    t.integer "district_id"
    t.integer "user_id"
  end

  create_table "feedbacks", force: true do |t|
    t.text     "content"
    t.string   "url"
    t.integer  "user_id"
    t.integer  "rubric_id"
    t.integer  "response_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "key_question_points", force: true do |t|
    t.integer  "key_question_question_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "key_question_questions", force: true do |t|
    t.integer  "question_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.text     "content"
    t.string   "category"
    t.datetime "sent_at"
    t.integer  "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mandrill_id"
    t.text     "mandrill_html"
  end

  create_table "network_partners", force: true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "network"
    t.integer "district_ids", array: true
    t.string  "specialize",   array: true
  end

  create_table "organizations", force: true do |t|
    t.string "name"
    t.string "logo"
  end

  create_table "organizations_users", id: false, force: true do |t|
    t.integer "organization_id", null: false
    t.integer "user_id",         null: false
  end

  create_table "participants", force: true do |t|
    t.integer  "user_id"
    t.integer  "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "invited_at"
    t.datetime "reminded_at"
    t.datetime "report_viewed_at"
  end

  add_index "participants", ["user_id", "assessment_id"], name: "index_participants_on_user_id_and_assessment_id", unique: true, using: :btree

  create_table "priorities", force: true do |t|
    t.integer  "assessment_id"
    t.integer  "order",         array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prospective_users", force: true do |t|
    t.string   "email",        default: "", null: false
    t.string   "district"
    t.string   "team_role"
    t.string   "name"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ga_dimension"
  end

  create_table "questions", force: true do |t|
    t.string   "headline"
    t.text     "content"
    t.integer  "order"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "help_text"
  end

  create_table "questions_rubrics", force: true do |t|
    t.integer "question_id"
    t.integer "rubric_id"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "redactor_assets", force: true do |t|
    t.integer  "user_id"
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], name: "idx_redactor_assetable", using: :btree
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_redactor_assetable_type", using: :btree

  create_table "responses", force: true do |t|
    t.integer  "responder_id"
    t.string   "responder_type"
    t.integer  "rubric_id"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "notification_sent_at"
  end

  add_index "responses", ["responder_id", "responder_type"], name: "index_responses_on_responder_id_and_responder_type", unique: true, using: :btree

  create_table "rubrics", force: true do |t|
    t.string   "name"
    t.decimal  "version"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
  end

  create_table "scores", force: true do |t|
    t.integer  "value"
    t.text     "evidence"
    t.integer  "response_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["response_id", "question_id"], name: "index_scores_on_response_id_and_question_id", unique: true, using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "tool_categories", force: true do |t|
    t.string  "title"
    t.integer "display_order"
    t.integer "tool_phase_id"
  end

  create_table "tool_phases", force: true do |t|
    t.string  "title"
    t.text    "description"
    t.integer "display_order"
  end

  create_table "tool_subcategories", force: true do |t|
    t.string  "title"
    t.integer "display_order"
    t.integer "tool_category_id"
  end

  create_table "tools", force: true do |t|
    t.string  "title"
    t.text    "description"
    t.string  "url"
    t.boolean "is_default"
    t.integer "display_order"
    t.integer "tool_subcategory_id"
    t.integer "user_id"
    t.integer "tool_category_id"
  end

  create_table "user_invitations", force: true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "team_role"
    t.string  "token"
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "team_role"
    t.boolean  "admin",                  default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "twitter"
    t.string   "avatar"
    t.string   "ga_dimension"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "walk_through_containers", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "walk_through_slides", force: true do |t|
    t.string   "title"
    t.string   "type"
    t.text     "content"
    t.text     "sidebar_content"
    t.string   "url"
    t.integer  "container_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
