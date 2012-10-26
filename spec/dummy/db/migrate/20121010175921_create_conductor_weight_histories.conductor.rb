# This migration comes from conductor (originally 20121010174950)
class CreateConductorWeightHistories < ActiveRecord::Migration
  def change
    create_table "conductor_weight_histories", :force => true do |t|
      t.string   "group_name"
      t.string   "alternative"
      t.decimal  "weight",        :precision => 8, :scale => 2
      t.datetime "computed_at"
      t.integer  "launch_window"
    end

    add_index "conductor_weight_histories", ["computed_at", "group_name"], :name => "conductor_wh_date_and_group_ndx"

  end
end
