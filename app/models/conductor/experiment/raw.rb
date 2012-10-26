module Conductor
  class Experiment
    class Raw < ActiveRecord::Base
      self.table_name = 'conductor_raw_experiments'

      attr_accessible :conversion_value, :group_name, :identity_id, :option_name, :alternative, :created_at, :updated_at, :goal

      validates_presence_of :group_name, :alternative
      scope :since, lambda { |a_date| { :conditions =>  ['created_at >= ?',a_date] }}

      def created_date
        self.created_at.strftime('%Y-%m-%d')
      end

      def self.purge(days_old=30)
        Conductor::Experiment::Raw.delete_all("created_at <= #{days_old.days.ago}")
      end
    end
  end
end
