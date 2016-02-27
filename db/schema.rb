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

ActiveRecord::Schema.define(version: 20160226162039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_requests", force: :cascade do |t|
    t.integer  "assessment_id"
    t.integer  "user_id"
    t.string   "roles",         default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  create_table "answers", force: :cascade do |t|
    t.integer  "value"
    t.text     "content"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assessments", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.datetime "due_date"
    t.datetime "meeting_date"
    t.integer  "user_id"
    t.integer  "rubric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "district_id"
    t.text     "message"
    t.datetime "assigned_at"
    t.string   "mandrill_id",     limit: 255
    t.text     "mandrill_html"
    t.text     "report_takeaway"
    t.string   "share_token"
  end

  create_table "assessments_facilitators", force: :cascade do |t|
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "assessments_network_partners", force: :cascade do |t|
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "assessments_viewers", force: :cascade do |t|
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "axes", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "axis_id"
  end

  create_table "categories_organizations", id: false, force: :cascade do |t|
    t.integer "category_id",     null: false
    t.integer "organization_id", null: false
  end

  create_table "data_access_questions", force: :cascade do |t|
    t.string   "data_storage"
    t.string   "who_access_data"
    t.string   "how_data_is_accessed"
    t.string   "why_data_is_accessed"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_entry_id"
  end

  add_index "data_access_questions", ["data_entry_id"], name: "index_data_access_questions_on_data_entry_id", using: :btree

  create_table "data_entries", force: :cascade do |t|
    t.integer  "general_data_question_id", null: false
    t.integer  "data_entry_question_id",   null: false
    t.integer  "data_access_question_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_id"
  end

  add_index "data_entries", ["data_access_question_id"], name: "index_data_entries_on_data_access_question_id", using: :btree
  add_index "data_entries", ["data_entry_question_id"], name: "index_data_entries_on_data_entry_question_id", using: :btree
  add_index "data_entries", ["general_data_question_id"], name: "index_data_entries_on_general_data_question_id", using: :btree
  add_index "data_entries", ["inventory_id"], name: "index_data_entries_on_inventory_id", using: :btree

  create_table "data_entry_questions", force: :cascade do |t|
    t.string   "who_enters_data"
    t.string   "how_data_is_entered"
    t.string   "when_data_is_entered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_entry_id"
  end

  add_index "data_entry_questions", ["data_entry_id"], name: "index_data_entry_questions_on_data_entry_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dismissed_popovers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "popover_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "district_messages", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "sender_name"
    t.string   "sender_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", force: :cascade do |t|
    t.string   "lea_id",        limit: 255
    t.string   "lea_type",      limit: 255
    t.string   "fipst",         limit: 255
    t.string   "stid",          limit: 255
    t.string   "name",          limit: 255
    t.string   "county_name",   limit: 255
    t.string   "county_number", limit: 255
    t.string   "street",        limit: 255
    t.string   "city",          limit: 255
    t.string   "state",         limit: 255
    t.string   "zip",           limit: 255
    t.string   "zip4",          limit: 255
    t.string   "phone",         limit: 255
    t.string   "mail_street",   limit: 255
    t.string   "mail_city",     limit: 255
    t.string   "mail_state",    limit: 255
    t.string   "mail_zip",      limit: 255
    t.string   "mail_zip4",     limit: 255
    t.string   "longitude",     limit: 255
    t.string   "latitude",      limit: 255
    t.string   "lowest_grade",  limit: 255
    t.string   "highest_grade", limit: 255
    t.string   "union",         limit: 255
    t.string   "csa",           limit: 255
    t.string   "cbsa",          limit: 255
    t.string   "metmic",        limit: 255
    t.string   "ulocal",        limit: 255
    t.string   "cdcode",        limit: 255
    t.string   "bound",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts_users", force: :cascade do |t|
    t.integer "district_id"
    t.integer "user_id"
  end

  create_table "faq_categories", force: :cascade do |t|
    t.string   "heading"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faq_questions", force: :cascade do |t|
    t.string   "role"
    t.string   "topic"
    t.integer  "category_id"
    t.text     "content"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text     "content"
    t.string   "url",         limit: 255
    t.integer  "user_id"
    t.integer  "rubric_id"
    t.integer  "response_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_data_questions", force: :cascade do |t|
    t.string   "subcategory"
    t.string   "point_of_contact_name"
    t.string   "point_of_contact_department"
    t.string   "data_capture"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_entry_id"
  end

  add_index "general_data_questions", ["data_entry_id"], name: "index_general_data_questions_on_data_entry_id", using: :btree

  create_table "general_inventory_questions", force: :cascade do |t|
    t.text     "product_name"
    t.text     "vendor"
    t.text     "point_of_contact_name"
    t.text     "point_of_contact_department"
    t.text     "pricing_structure"
    t.decimal  "price",                       precision: 9, scale: 2
    t.text     "data_type",                                           default: [], array: true
    t.text     "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_entry_id"
  end

  add_index "general_inventory_questions", ["product_entry_id"], name: "index_general_inventory_questions_on_product_entry_id", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.string   "name",             null: false
    t.datetime "deadline",         null: false
    t.integer  "districts_id",     null: false
    t.integer  "product_entry_id", null: false
    t.integer  "data_entry_id",    null: false
  end

  add_index "inventories", ["data_entry_id"], name: "index_inventories_on_data_entry_id", using: :btree
  add_index "inventories", ["product_entry_id"], name: "index_inventories_on_product_entry_id", using: :btree

  create_table "key_question_points", force: :cascade do |t|
    t.integer  "key_question_question_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "key_question_questions", force: :cascade do |t|
    t.integer  "question_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "learning_questions", force: :cascade do |t|
    t.integer  "assessment_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "learning_questions", ["assessment_id"], name: "index_learning_questions_on_assessment_id", using: :btree
  add_index "learning_questions", ["created_at"], name: "index_learning_questions_on_created_at", using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.string   "category",      limit: 255
    t.datetime "sent_at"
    t.integer  "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mandrill_id",   limit: 255
    t.text     "mandrill_html"
  end

  create_table "network_partners", force: :cascade do |t|
    t.string  "first_name",   limit: 255
    t.string  "last_name",    limit: 255
    t.string  "email",        limit: 255
    t.string  "network",      limit: 255
    t.integer "district_ids",             array: true
    t.string  "specialize",               array: true
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "logo"
  end

  create_table "organizations_users", id: false, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "user_id",         null: false
  end

  create_table "participants", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "invited_at"
    t.datetime "reminded_at"
    t.datetime "report_viewed_at"
  end

  add_index "participants", ["user_id", "assessment_id"], name: "index_participants_on_user_id_and_assessment_id", unique: true, using: :btree

  create_table "priorities", force: :cascade do |t|
    t.integer  "assessment_id"
    t.integer  "order",         array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_entries", force: :cascade do |t|
    t.integer  "general_inventory_question_id", null: false
    t.integer  "product_question_id"
    t.integer  "usage_question_id",             null: false
    t.integer  "technical_question_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_id"
  end

  add_index "product_entries", ["general_inventory_question_id"], name: "index_product_entries_on_general_inventory_question_id", using: :btree
  add_index "product_entries", ["inventory_id"], name: "index_product_entries_on_inventory_id", using: :btree
  add_index "product_entries", ["product_question_id"], name: "index_product_entries_on_product_question_id", using: :btree
  add_index "product_entries", ["technical_question_id"], name: "index_product_entries_on_technical_question_id", using: :btree
  add_index "product_entries", ["usage_question_id"], name: "index_product_entries_on_usage_question_id", using: :btree

  create_table "product_questions", force: :cascade do |t|
    t.text     "how_its_assigned", default: [], array: true
    t.text     "how_its_used",     default: [], array: true
    t.text     "how_its_accessed", default: [], array: true
    t.text     "audience",         default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_entry_id"
  end

  add_index "product_questions", ["product_entry_id"], name: "index_product_questions_on_product_entry_id", using: :btree

  create_table "prospective_users", force: :cascade do |t|
    t.string   "email",        limit: 255, default: "", null: false
    t.string   "district",     limit: 255
    t.string   "team_role",    limit: 255
    t.string   "name",         limit: 255
    t.string   "ip_address",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ga_dimension", limit: 255
  end

  create_table "questions", force: :cascade do |t|
    t.string   "headline",    limit: 255
    t.text     "content"
    t.integer  "order"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "help_text"
  end

  create_table "questions_rubrics", force: :cascade do |t|
    t.integer "question_id"
    t.integer "rubric_id"
  end

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username",   limit: 255
    t.integer  "item"
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "redactor_assets", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
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

  create_table "responses", force: :cascade do |t|
    t.integer  "responder_id"
    t.string   "responder_type",       limit: 255
    t.integer  "rubric_id"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "notification_sent_at"
  end

  add_index "responses", ["responder_id", "responder_type"], name: "index_responses_on_responder_id_and_responder_type", unique: true, using: :btree

  create_table "rubrics", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.decimal  "version"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
  end

  create_table "scores", force: :cascade do |t|
    t.integer  "value"
    t.text     "evidence"
    t.integer  "response_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["response_id", "question_id"], name: "index_scores_on_response_id_and_question_id", unique: true, using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "technical_questions", force: :cascade do |t|
    t.text     "platform",         default: [], array: true
    t.text     "hosting"
    t.text     "connectivity"
    t.text     "single_sign_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_entry_id"
  end

  add_index "technical_questions", ["product_entry_id"], name: "index_technical_questions_on_product_entry_id", using: :btree

  create_table "tool_categories", force: :cascade do |t|
    t.string  "title"
    t.integer "display_order"
    t.integer "tool_phase_id"
  end

  create_table "tool_phases", force: :cascade do |t|
    t.string  "title"
    t.text    "description"
    t.integer "display_order"
  end

  create_table "tool_subcategories", force: :cascade do |t|
    t.string  "title"
    t.integer "display_order"
    t.integer "tool_category_id"
  end

  create_table "tools", force: :cascade do |t|
    t.string  "title"
    t.text    "description"
    t.string  "url"
    t.boolean "is_default"
    t.integer "display_order"
    t.integer "tool_subcategory_id"
    t.integer "user_id"
    t.integer "tool_category_id"
  end

  create_table "usage_questions", force: :cascade do |t|
    t.text     "school_usage"
    t.text     "usage"
    t.text     "vendor_data"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_entry_id"
  end

  add_index "usage_questions", ["product_entry_id"], name: "index_usage_questions_on_product_entry_id", using: :btree

  create_table "user_invitations", force: :cascade do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "team_role"
    t.string  "token"
    t.integer "assessment_id"
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: ""
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   limit: 255
    t.string   "team_role",              limit: 255
    t.boolean  "admin",                              default: false
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "twitter",                limit: 255
    t.string   "avatar",                 limit: 255
    t.string   "ga_dimension",           limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "data_entries", "data_access_questions", on_delete: :cascade
  add_foreign_key "data_entries", "data_entry_questions", on_delete: :cascade
  add_foreign_key "data_entries", "general_data_questions", on_delete: :cascade
  add_foreign_key "inventories", "data_entries", on_delete: :cascade
  add_foreign_key "inventories", "product_entries", on_delete: :cascade
  add_foreign_key "product_entries", "general_inventory_questions", on_delete: :cascade
  add_foreign_key "product_entries", "product_questions", on_delete: :cascade
  add_foreign_key "product_entries", "technical_questions", on_delete: :cascade
  add_foreign_key "product_entries", "usage_questions", on_delete: :cascade
end
