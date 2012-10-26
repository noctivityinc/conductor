# == Schema Information
#
# Table name: conductor_weighted_experiments
#
#  id          :integer         not null, primary key
#  group_name  :string(255)
#  option_name :string(255)
#  weight      :decimal(8, 2)
#  created_at  :datetime
#  updated_at  :datetime
#

class Conductor::Experiment::Weight < ActiveRecord::Base
  set_table_name "conductor_weighted_experiments"

  named_scope :for_group, lambda { |group_name| { :conditions =>  ['group_name = ?',group_name] }}
  named_scope :with_alternative, lambda { |alternative| { :conditions =>  ['alternative = ?',alternative] }}
end
