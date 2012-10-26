module Conductor
  class Experiment
    
    class Daily < ActiveRecord::Base
      self.table_name = "conductor_daily_experiments"

      attr_accessible :activity_date, :conversion_value, :conversions, :group_name, :option_name, :views, :alternative

      scope :since, lambda { |a_date| { :conditions =>  ['activity_date >= ?',a_date] }}
      scope :for_group, lambda { |group_name| { :conditions =>  ['group_name = ?',group_name] }}

      def self.find_equalization_period_stats_for(group_name, alternatives=nil)
        alternative_filter = alternatives ? alternatives.inject([]) {|res,x| res << "alternative = '#{Conductor.sanitize(x)}'"}.join(' OR ') : 'true'

        sql = "SELECT alternative, min(activity_date) AS activity_date
        FROM conductor_daily_experiments
        WHERE group_name = '#{group_name}'
        AND (#{alternative_filter})
        GROUP BY alternative
        HAVING min(activity_date) > '#{Date.today - Conductor.equalization_period}'"

        self.find_by_sql(sql)
      end


      def self.find_post_equalization_period_stats_for(group_name, alternatives=nil)
        alternative_filter = alternatives ? alternatives.inject([]) {|res,x| res << "alternative = '#{Conductor.sanitize(x)}'"}.join(' OR ') : 'true'

        sql = "SELECT alternative, min(activity_date) AS activity_date, sum(views) AS views, sum(conversions) AS conversions, sum(conversion_value) AS conversion_value
        FROM conductor_daily_experiments
        WHERE group_name = '#{group_name}'
        AND (#{alternative_filter})
        AND activity_date >=
        (SELECT max(min_date) FROM
        (SELECT alternative, min(activity_date) AS min_date
        FROM conductor_daily_experiments
        WHERE activity_date >= '#{Date.today - Conductor.inclusion_period}'
        GROUP BY alternative) AS a)
        GROUP BY alternative
        HAVING min(activity_date) <= '#{Date.today - Conductor.equalization_period}'"

        self.find_by_sql(sql)
      end

    end
  end
end
