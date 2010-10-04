class Conductor
  class Weights
    class << self

      # Returns all the weights for a given group.  In the event that the alternatives specified for the
      # group do not match all the alternatives previously computed for the group, new weights are
      # generated.  The cache is used to speed up this check
      def find_or_create(group_name, alternatives)
        weights_for_group = Conductor.cache.read("Conductor::Experiment::#{Conductor.attribute_for_weighting}::#{group_name}::Alternatives")

        alternatives_array = weights_for_group.map(&:alternative).sort if weights_for_group
        if alternatives_array.eql?(alternatives.sort)
          Conductor.log('alternatives equal to cache')
          return weights_for_group
        else
          # Conductor.log('alternatives NOT equal to cache.  Need to recompute')
          compute(group_name, alternatives)

          # get the new weights
          weights_for_group = Conductor::Experiment::Weight.find(:all, :conditions => "group_name = '#{group_name}'")
          Conductor.cache.delete("Conductor::Experiment::#{Conductor.attribute_for_weighting}::#{group_name}::Alternatives")
          Conductor.cache.write("Conductor::Experiment::#{Conductor.attribute_for_weighting}::#{group_name}::Alternatives", weights_for_group)
          return weights_for_group
        end
      end

      # Computes the weights for a group based on the attribute for weighting and 
      # activity for the last two weeks.
      #
      # If no conversions have taken place yet for a group, all alternatives are weighted 
      # equally.
      #
      # TODO: add notification table and all notification if there are no conversions and we are out of the equalization period
      def compute(group_name, alternatives)
        # create the conditions after sanitizing sql.
        alternative_filter = alternatives.inject([]) {|res,x| res << "alternative = '#{Conductor.sanitize(x)}'"}.join(' OR ')

        # pull daily data and recompute if daily data
        group_rows = Conductor::Experiment::Daily.since(14.days.ago).for_group(group_name).find(:all, :conditions => alternative_filter)

        unless group_rows.empty?
          Conductor::Experiment::Weight.delete_all(:group_name => group_name) # => remove all old data for group
          total = group_rows.sum_it(Conductor.attribute_for_weighting)
          data = total > 0 ? compute_weights_for_group(group_name, group_rows, total) : assign_equal_weights(group_rows)
          update_weights_in_db(group_name, data)
        end
      end

      private

        # loops through all the alternatives for a given group and computes the weights for
        # each alternative
        def compute_weights_for_group(group_name, group_rows, total)
          data = []
          recently_launched = []
          
          # calculate weights for each alternative
          weighted_moving_avg, total, max_weight = compute_weighted_moving_stats(group_rows)

          group_rows.group_by(&:alternative).each do |alternative_name, alternatives|
            days_ago = compute_days_ago(alternatives)

            if days_ago >= Conductor.equalization_period
              data << {:name => alternative_name, :weight => (weighted_moving_avg[alternative_name] / total)}
            else
              recently_launched << {:name => alternative_name, :days_ago => days_ago}
            end
          end

          weight_recently_launched(data, max_weight, recently_launched)
          return data
        end

        def compute_weighted_moving_stats(group_rows)
          weighted_moving_avg = {}
          group_rows.group_by(&:alternative).each do |alternative_name, alternatives|
            weighted_moving_avg.merge!({"#{alternative_name}" => alternatives.sort_by(&:activity_date).weighted_mean_of_attribute(Conductor.attribute_for_weighting)}) 
          end
          
          # calculate total and max_weight for weighted moving averages
          total = weighted_moving_avg.values.sum
          max_weight = weighted_moving_avg.values.max
          
          return weighted_moving_avg, total, max_weight
        end
        
        def compute_days_ago(alternatives)
          first_found_date = alternatives.map(&:activity_date).min
          (Date.today - first_found_date.to_date).to_f
        end

        def weight_recently_launched(data, max_weight, recently_launched)
          # loop through recently_launched to create weights for table
          # the handicap sets a newly launched item to the max weight * MAX_WEIGHTING_FACTOR and then
          # slowly lowers its power until the launch period is over
          max_weight = 1 if data.empty?
          recently_launched.each do |alternative|
            handicap = (alternative[:days_ago].to_f / Conductor.equalization_period)
            launch_window = (Conductor.equalization_period - alternative[:days_ago]) if Conductor.equalization_period > alternative[:days_ago]
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
