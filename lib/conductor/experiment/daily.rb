# == Schema Information
#
# Table name: conductor_daily_experiments
#
#  id               :integer         not null, primary key
#  activity_date    :date
#  group_name       :string(255)
#  option_name      :string(255)
#  conversion_value :decimal(8, 2)
#  views            :integer
#  conversions      :integer
#

class Conductor::Experiment::Daily < ActiveRecord::Base
  set_table_name "conductor_daily_experiments"
  named_scope :since, lambda { |a_date| { :conditions =>  ['activity_date >= ?',a_date] }}
end
