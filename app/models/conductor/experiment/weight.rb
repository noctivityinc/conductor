module Conductor
  class Experiment
    class Weight < ActiveRecord::Base
      self.table_name = 'conductor_weighted_experiments'
      attr_accessible :group_name, :option_name, :weight, :alternative, :created_at, :updated_at

      scope :for_group, lambda { |group_name| { :conditions =>  ['group_name = ?',group_name] }}
      scope :with_alternative, lambda { |alternative| { :conditions =>  ['alternative = ?',alternative] }}
    end
  end
end
