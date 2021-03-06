module Conductor
  class RollUp
    def self.process
      Conductor::Experiment::Raw.since(14.days.ago).group_by(&:created_date).each do |day, daily_rows|

        # remove all the existing data for that day
        Conductor::Experiment::Daily.delete_all(:activity_date => day)

        daily_rows.group_by(&:group_name).each do |group_name, group_rows|
          group_rows.group_by(&:alternative).each do |alternative_name, alternatives|
            conversion_value = alternatives.select {|x| !x.conversion_value.nil?}.inject(0) {|res, x| res += x.conversion_value}
            views = alternatives.count
            conversions = alternatives.count {|x| !x.conversion_value.nil?}
            Conductor::Experiment::Daily.create!(:activity_date => day,
                                                 :group_name => group_name,
                                                 :alternative => alternative_name,
                                                 :conversion_value => conversion_value,
                                                 :views => views,
                                                 :conversions => conversions )
          end
          
          # delete the cache for this group so it can be recreated with the new values
          Conductor.cache.delete("Conductor::Experiment::#{group_name}::Alternatives")
        end
      end
    end
  end
end
