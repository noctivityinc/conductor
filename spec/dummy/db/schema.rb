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

ActiveRecord::Schema.define(:version => 20121010175921) do

  create_table "conductor_daily_experiments", :force => true do |t|
    t.date    "activity_date"
    t.string  "group_name"
    t.string  "alternative"
    t.decimal "conversion_value", :precision => 8, :scale => 2
    t.integer "views"
    t.integer "conversions"
  end

  add_index "conductor_daily_experiments", ["activity_date"], :name => "index_conductor_daily_experiments_on_activity_date"
  add_index "conductor_daily_experiments", ["group_name"], :name => "index_conductor_daily_experiments_on_group_name"

  create_table "conductor_raw_experiments", :force => true do |t|
    t.string   "identity_id"
    t.string   "group_name"
    t.string   "alternative"
    t.decimal  "conversion_value", :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "goal"
  end

  create_table "conductor_weight_histories", :force => true do |t|
    t.string   "group_name"
    t.string   "alternative"
    t.decimal  "weight",        :precision => 8, :scale => 2
    t.datetime "computed_at"
    t.integer  "launch_window"
  end

  add_index "conductor_weight_histories", ["computed_at", "group_name"], :name => "conductor_wh_date_and_group_ndx"

  create_table "conductor_weighted_experiments", :force => true do |t|
    t.string   "group_name"
    t.string   "alternative"
    t.decimal  "weight",      :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conductor_weighted_experiments", ["group_name"], :name => "index_conductor_weighted_experiments_on_group_name"

end
