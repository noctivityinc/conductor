class CreateConductorDailyExperiments < ActiveRecord::Migration
  def change
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

  end
end
