ActiveRecord::Schema.define(:version => 0) do
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