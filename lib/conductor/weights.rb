class Conductor
  class Weights
    class << self
      def compute
        Conductor::WeightedExperiment.delete_all # => remove all old data

        # loop through each group and determing weight of options
        Conductor::DailyExperiment.since(14.days.ago).group_by(&:group_name).each do |group_name, group_rows|
          total = group_rows.sum_it(:conversion_value)
          data = total ? compute_weights_for_group(group_name, group_rows, total) : assign_equal_weights(group_rows)
          update_weights_in_db(group_name, data)
        end
      end

      private

        # loops through all the options for a given group and computes the weights for
        # each alternative
        def compute_weights_for_group(group_name, group_rows, total)
          Conductor.log('compute_weights_for_group')

          data = []
          recently_launched = []
          max_weight = 0

          group_rows.group_by(&:option_name).each do |option_name, option_rows|
            first_found_date = option_rows.map(&:activity_date).sort.first
            days_ago = Date.today - first_found_date

            if days_ago >= MINIMUM_LAUNCH_DAYS
              data << compute_weight_for_option(option_name, option_rows, max_weight, total)
            else
              Conductor.log("adding #{option_name} to recently launched array")
              recently_launched << {:name => option_name, :days_ago => days_ago}
            end
          end

          data += weight_recently_launched(max_weight, recently_launched)
          return data
        end

        def compute_weight_for_option(option_name, option_rows, max_weight, total)
          Conductor.log("compute_weight_for_option for #{option_name}")

          aggregates = {:name => option_name}

          weight = option_rows.sum_it(:conversion_value) / total
          max_weight = weight if weight > max_weight
          aggregates.merge!({:weight => weight})

          return aggregates
        end

        def weight_recently_launched(max_weight, recently_launched)
          # loop through recently_launched to create weights for table
          # the handicap sets a newly launched item to the max weight * MAX_WEIGHTING_FACTOR and then
          # slowly lowers its power until the launch period is over
          data = []
          max_weight = 0 ? 1 : max_weight # => if a max weight could not be computed, set it to 1
          Conductor.log("max weight: #{max_weight}")
          recently_launched.each do |option|
            handicap = (option[:days_ago].to_f / MINIMUM_LAUNCH_DAYS)
            launch_window = (MINIMUM_LAUNCH_DAYS - option[:days_ago]) if MINIMUM_LAUNCH_DAYS > option[:days_ago]
            Conductor.log("Handicap for #{option[:name]} is #{handicap} (#{option[:days_ago]} days ago)")
            data << {:name => option[:name], :weight => max_weight * MAX_WEIGHTING_FACTOR * (1 - handicap), :launch_window => launch_window}
          end
          data
        end

        def assign_equal_weights(group_rows)
          Conductor.log('assign_equal_weights')

          # weight everything the same since there were no conversions
          data = []
          group_rows.group_by(&:option_name).each do |option_name, option_rows|
            data << {:name => option_name, :weight => 1}
          end
          data
        end

        # creates new records in weights table and adds weights to weight history for reporting
        def update_weights_in_db(group_name, data)
          data.each { |option|
            Conductor::WeightedExperiment.create!(:group_name => group_name, :option_name => option[:name], :weight => option[:weight])
            Conductor::WeightHistory.create!(:group_name => group_name, :option_name => option[:name], :weight => option[:weight], :launch_window => option[:launch_window], :computed_at => Time.now)
          }
        end

    end
  end
end
