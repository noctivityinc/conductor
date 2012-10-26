class CreateConductorExperimentWeights < ActiveRecord::Migration
  def change
    create_table "conductor_weighted_experiments", :force => true do |t|
      t.string   "group_name"
      t.string   "alternative"
      t.decimal  "weight",      :precision => 8, :scale => 2
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "conductor_weighted_experiments", ["group_name"], :name => "index_conductor_weighted_experiments_on_group_name"
  end
end
