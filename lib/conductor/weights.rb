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
      # activity for the inclusion period.
      #
      # If no conversions have taken place yet for a group, all alternatives are weighted
      # equally.
      #
      # TODO: add notification table and all notification if there are no conversions and we are out of the equalization period
      def compute(group_name, alternatives)
        Conductor::Experiment::Weight.delete_all(:group_name => group_name)
        
        data = []
        equalization_period_data = Conductor::Experiment::Daily.find_equalization_period_stats_for(group_name, alternatives)
        post_equalization_data = Conductor::Experiment::Daily.find_post_equalization_period_stats_for(group_name, alternatives)

        # handle all post_equalization_data
        max_weight = 0
        unless post_equalization_data.empty?
          total = post_equalization_data.sum_it(Conductor.attribute_for_weighting)
          data = (total > 0) ? compute_weights(post_equalization_data, total, max_weight) : assign_equal_weights(post_equalization_data)
        end

        # add weights for recently launched
        weight_recently_launched(data, max_weight, equalization_period_data) unless equalization_period_data.empty?
        
        # add to database
        update_weights_in_db(group_name, data)
      end

      private

        def compute_weights(post_equalization_data, total, max_weight)
          data = []
          post_equalization_data.each {|x|
            weight = (x.send(Conductor.attribute_for_weighting).to_f / total.to_f)
            max_weight = weight if weight > max_weight
            data << {:name => x.alternative, :weight => weight}
          }
          data
        end

        # loop through recently_launched to create weights for table
        # the handicap sets a newly launched item to the max weight * MAX_WEIGHTING_FACTOR and then
        # slowly lowers its power until the launch period is over
        def weight_recently_launched(data, max_weight, equalization_period_data)
          max_weight = 1 if data.empty?
          equalization_period_data.each do |x|
            days_ago = (Date.today - x.activity_date)
            handicap = (days_ago.to_f / Conductor.equalization_period)
            launch_window = (Conductor.equalization_period - days_ago) 
            
            Conductor.log("Handicap for #{x.alternative} is #{handicap} (#{days_ago} days ago)")
            data << {:name => x.alternative, :weight => max_weight * MAX_WEIGHTING_FACTOR * (1 - handicap), :launch_window => launch_window}
          end
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
