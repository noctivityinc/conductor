# == Schema Information
#
# Table name: conductor_raw_experiments
#
#  id               :integer         not null, primary key
#  identity_id      :string(255)
#  group_name       :string(255)
#  option_name      :string(255)
#  conversion_value :decimal(8, 2)
#  created_at       :datetime
#  updated_at       :datetime
#

class Conductor::RawExperiment < ActiveRecord::Base
  set_table_name "conductor_raw_experiments"
  
  validates_presence_of :group_name, :option_name
  
  def created_date
    self.created_at.strftime('%Y-%m-%d')
  end
end
