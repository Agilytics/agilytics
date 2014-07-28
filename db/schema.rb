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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130611225046) do

  create_table "agile_users", :force => true do |t|
    t.string   "pid"
    t.string   "name"
    t.string   "display_name"
    t.string   "email_address"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "boards", :force => true do |t|
    t.string   "pid"
    t.string   "name"
    t.boolean  "to_analyze"
    t.boolean  "to_analyze_backlog"
    t.datetime "last_updated"
    t.integer  "site_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sprint_stories", :force => true do |t|
    t.string   "pid"
    t.string   "acuity"
    t.datetime "create_date"
    t.boolean  "is_done"
    t.integer  "size",           :default => 0
    t.integer  "init_size",      :default => 0
    t.string   "location"
    t.string   "status"
    t.datetime "init_date"
    t.boolean  "is_initialized"
    t.integer  "story_id"
    t.integer  "sprint_id"
    t.integer  "assignee_id"
    t.integer  "reporter_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "sprints", :force => true do |t|
    t.string   "pid"
    t.string   "sprint_id"
    t.string   "name"
    t.boolean  "closed"
    t.boolean  "to_analyze"
    t.boolean  "have_all_changes"
    t.boolean  "have_processed_all_changes"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "board_id"
    t.integer  "init_velocity"
    t.integer  "added_velocity"
    t.integer  "estimate_changed_velocity"
    t.integer  "total_velocity"
    t.integer  "removed_committed_velocity"
    t.integer  "removed_added_velocity"
    t.integer  "init_commitment"
    t.integer  "added_commitment"
    t.integer  "estimate_changed"
    t.integer  "total_commitment"
    t.integer  "missed_init_commitment"
    t.integer  "missed_added_commitment"
    t.integer  "missed_estimate_changed"
    t.integer  "missed_total_commitment"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "stories", :force => true do |t|
    t.string   "pid"
    t.string   "story_key"
    t.string   "acuity"
    t.datetime "create_date"
    t.datetime "done_date"
    t.boolean  "done"
    t.integer  "size"
    t.string   "status"
    t.string   "location"
    t.integer  "board_id"
    t.integer  "sprint_id"
    t.integer  "assignee_id"
    t.integer  "reporter_id"
    t.string   "story_type"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
