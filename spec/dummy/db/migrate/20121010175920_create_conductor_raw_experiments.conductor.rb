# This migration comes from conductor (originally 20121010174835)
class CreateConductorRawExperiments < ActiveRecord::Migration
  def change
    create_table "conductor_raw_experiments", :force => true do |t|
      t.string   "identity_id"
      t.string   "group_name"
      t.string   "alternative"
      t.decimal  "conversion_value", :precision => 8, :scale => 2
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "goal"
    end
  end
end
