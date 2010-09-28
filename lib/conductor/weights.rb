class Conductor
  class Weights
    class << self
      def compute
        Conductor::Experiment::Weight.delete_all # => remove all old data

        # loop through each group and determing weight of alternatives
        Conductor::Experiment::Daily.since(14.days.ago).group_by(&:group_name).each do |group_name, group_rows|
          total = group_rows.sum_it(:conversion_value)
          data = total ? compute_weights_for_group(group_name, group_rows, total) : assign_equal_weights(group_rows)
          update_weights_in_db(group_name, data)
        end
      end

      private

        # loops through all the alternatives for a given group and computes the weights for
        # each alternative
        def compute_weights_for_group(group_name, group_rows, total)
          Conductor.log('compute_weights_for_group')

          data = []
          recently_launched = []
          max_weight = 0

          group_rows.group_by(&:alternative).each do |alternative_name, alternatives|
            first_found_date = alternatives.map(&:activity_date).sort.first
            days_ago = Date.today - first_found_date

            if days_ago >= MINIMUM_LAUNCH_DAYS
              data << compute_weight_for_alternative(alternative_name, alternatives, max_weight, total)
            else
              Conductor.log("adding #{alternative_name} to recently launched array")
              recently_launched << {:name => alternative_name, :days_ago => days_ago}
            end
          end

          data += weight_recently_launched(max_weight, recently_launched)
          return data
        end

        def compute_weight_for_alternative(alternative_name, alternatives, max_weight, total)
          Conductor.log("compute_weight_for_alternative for #{alternative_name}")

          aggregates = {:name => alternative_name}

          weight = alternatives.sum_it(:conversion_value) / total
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
          recently_launched.each do |alternative|
            handicap = (alternative[:days_ago].to_f / MINIMUM_LAUNCH_DAYS)
            launch_window = (MINIMUM_LAUNCH_DAYS - alternative[:days_ago]) if MINIMUM_LAUNCH_DAYS > alternative[:days_ago]
            Conductor.log("Handicap for #{alternative[:name]} is #{handicap} (#{alternative[:days_ago]} days ago)")
            data << {:name => alternative[:name], :weight => max_weight * MAX_WEIGHTING_FACTOR * (1 - handicap), :launch_window => launch_window}
          end
          data
        end

        def assign_equal_weights(group_rows)
          Conductor.log('assign_equal_weights')

          # weight everything the same since there were no conversions
          data = []
          group_rows.group_by(&:alternative).each do |alternative_name, alternatives|
            data << {:name => alternative_name, :weight => 1}
          end
          data
        end

        # creates new records in weights table and adds weights to weight history for reporting
        def update_weights_in_db(group_name, data)
          data.each { |alternative|
            Conductor::Experiment::Weight.create!(:group_name => group_name, :alternative => alternative[:name], :weight => alternative[:weight])
            Conductor::Experiment::History.create!(:group_name => group_name, :alternative => alternative[:name], :weight => alternative[:weight], :launch_window => alternative[:launch_window], :computed_at => Time.now)
          }
        end

    end
  end
end
