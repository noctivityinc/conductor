class Conductor
  class Experiment
    class << self
      # Selects the best alternative for a given group
      #
      # Method also saves the selection to the
      # database so everything happens in one move
      #
      # options allow you to specify a specific GOAL
      # in case you have multiple goals per site.  For example,
      # if you are using Conductor to maximize newsletter signups
      # and orders, you might have:
      # {:goal => "signup"}
      # and
      # {:goal => "purchase" }
      #
      # goals are important since you can specify which goal converted
      # with the track! method to only update records for that
      # specific goal.
      #
      def pick(group_name, alternatives, options={})
        group_name = sanitize(group_name) # => clean up and standardize

        # check for previous selection
        selection = Conductor.cache.read("Conductor::#{Conductor.identity}::Experience::#{group_name}")

        unless selection
          selection = select_alternative_for_group(group_name, alternatives)
          Conductor::Experiment::Raw.create!({:identity_id => Conductor.identity.to_s, :group_name => group_name, :alternative => selection}.merge!(options))
          Conductor.cache.write("Conductor::#{Conductor.identity}::Experience::#{group_name}", selection)
        end

        return selection
      end

      # returns the raw weighting table for all alternatives for a specified group
      def weights(group_name, alternatives)
        group_name = sanitize(group_name) # => clean up and standardize
        return generate_weighting_table(group_name, alternatives)
      end

      # Records a conversion for the visitor.
      #
      # May optionally supply a conversion value and goal.
      #
      # Conversion value is specified as {:value => 123.45}
      #
      # If no goal is specified as an option, than ALL selected alternatives
      # for the experiments for a specific user will be updated with the
      # conversion value.  If a goal is specified, then only those
      # records will be updated.
      #
      # To clarify by explaination -
      #
      # Assume you are selecting a landing page to maximize newsletter
      # signups and are selecting a price point to maximize purchases.
      # In this case you would have two goals -
      #  - signup
      #  - purchase
      #
      # Now, if we assume that for visitor 24601 a landing page and
      # price point are selected before they signup for the newsletter,
      # if you called track! after a newsletter signup occurred without
      # specifying the goal, then a conversion would ALSO (and incorrectly)
      # be recorded by the PURCHASE goal as well as the SIGNUP goal.
      #
      # What you needed to do was call track!({:goal => 'signup'}) to correctly record
      # a conversion for visitor 24601 and the newsletter signup only.
      #
      def track!(options={})
        value = (options.delete(:value) || 1) # => pull the conversion value and remove from hash or set value to 1
        experiments = Conductor::Experiment::Raw.find(:all, :conditions => {:identity_id => Conductor.identity}.merge!(options))
        experiments.each {|x| x.update_attributes(:conversion_value => value)} if experiments
      end

      private

        def select_alternative_for_group(group_name, alternatives)
          # create weighting table
          weighting_table = generate_weighting_table(group_name, alternatives)

          # make a selection from weighted hash
          return choose_weighted(weighting_table)
        end

        # Returns a hash of alternatives with weights based on conversion
        # e.g. {:option_a => .25, :option_b => .25, :option_c => .50}
        #
        # Note: We create sql where statement that includes the list of
        # alternatives to select from in case an existing group
        # has an alternative you no longer want to include in the result set
        #
        # TODO: store all weights for a group in cache and then weed out 
        # those not in the alternatives list
        #
        def generate_weighting_table(group_name, alternatives)
          # create the conditions after sanitizing sql.
          alternative_filter = alternatives.inject([]) {|res,x| res << "alternative = '#{sanitize(x)}'"}.join(' OR ')

          conditions = "group_name = '#{group_name}' AND (#{alternative_filter})"

          # get the alternatives from the database
          weights ||= Conductor::Experiment::Weight.find(:all, :conditions => conditions)

          # create selection hash
          weighting_table = weights.inject({}) {|res, x| res.merge!({x.alternative => x.weight})}

          # is anything missing?
          alternative_names = weights.map(&:alternative)
          missing = alternatives - alternative_names

          # if anything is missing, add it to the weighted list
          unless missing.empty?
            max_weight = weights.empty? ? 1 : weights.max {|a,b| a.weight <=> b.weight}.weight
            missing.each do |name|
              weighting_table.merge!({name => max_weight * MAX_WEIGHTING_FACTOR})
            end
          end

          return weighting_table
        end

        # selects a random float
        def float_rand(start_num, end_num=0)
          width = end_num-start_num
          return (rand*width)+start_num
        end

        # choose a random alternative based on weights
        # from recipe 5.11 in ruby cookbook
        def choose_weighted(weighted)
          sum = weighted.inject(0) do |sum, item_and_weight|
            sum += item_and_weight[1]
          end
          target = float_rand(sum)
          weighted.each do |item, weight|
            return item if target <= weight
            target -= weight
          end
        end

        def normalize!(weighted)
          sum = weighted.inject(0) do |sum, item_and_weight|
            sum += item_and_weight[1]
          end
          sum = sum.to_f
          weighted.each { |item, weight| weighted[item] = weight/sum }
        end

        def sanitize(str)
          str.gsub(/\s/,'_').downcase
        end

    end
  end
end
