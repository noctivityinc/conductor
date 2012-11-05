# This migration comes from conductor (originally 20121105213325)
class AddIndexesToRaw < ActiveRecord::Migration
  def self.up
    add_index 'conductor_raw_experiments', :created_at
    add_index 'conductor_raw_experiments', :identity_id
    add_index 'conductor_raw_experiments', [:identity_id, :goal], :name => "ndx_identity_goal"
  end
end
