class Conductor
  class RollUp
    def self.process
      Conductor::RawExperiment.all.group_by(&:created_date).each do |day, daily_rows|

        # remove all the existing data for that day
        Conductor::DailyExperiment.delete_all(:activity_date => day)

        daily_rows.group_by(&:group_name).each do |group_name, group_rows|
          group_rows.group_by(&:option_name).each do |option_name, option_rows|
            conversion_value = option_rows.select {|x| !x.conversion_value.nil?}.inject(0) {|res, x| res += x.conversion_value}
            views = option_rows.count
            conversions = option_rows.count {|x| !x.conversion_value.nil?}
            Conductor::DailyExperiment.create!(:activity_date => day,
                                         :group_name => group_name,
                                         :option_name => option_name,
                                         :conversion_value => conversion_value,
                                         :views => views,
                                         :conversions => conversions )
          end
        end
      end
    end
  end
end
