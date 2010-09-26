require 'helper'

class TestConductor < Test::Unit::TestCase
  #Wipes cache, D/B prior to doing a test run.
   VectorSixteen.cache.clear

   test "will automatically assign an identity if none is specified" do
     assert VectorSixteen.identity != nil
   end

   test "will select one of the specified options randomly" do
     selected = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
     assert ["a", "b", "c"].include? selected
   end

   test "will always select the same option using the cache" do
     VectorSixteen.identity = ActiveSupport::SecureRandom.hex(16)

     selected = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
     different = false

     (1..100).each do |x|
       different = true if selected != VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"])
     end

     assert !different
   end

   test "will select a lander and then successfully record a conversion" do
     VectorSixteen.identity = ActiveSupport::SecureRandom.hex(16)
     selected = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique

     VectorSixteen::Experiment.track!

     experiments = V16::RawExperiment.find_all_by_identity_id(VectorSixteen.identity)
     assert_equal 1, experiments.count
     assert_equal 1, experiments.first.conversion_value
   end

   test "will select a lander and then successfully record custom conversion value" do
      VectorSixteen.identity = ActiveSupport::SecureRandom.hex(16)
      selected = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique

      VectorSixteen::Experiment.track!({:value => 12.34})

      experiments = V16::RawExperiment.find_all_by_identity_id(VectorSixteen.identity)
      assert_equal 1, experiments.count
      assert_equal 12.34, experiments.first.conversion_value
    end



   test "will record three different experiments with two goals but a single conversion for all goals for the same identity" do
     VectorSixteen.identity = ActiveSupport::SecureRandom.hex(16)
     first = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"], {:goal => 'goal_1'}) # => value must be unique
     second = VectorSixteen::Experiment.pick('b_group', ["1", "2", "3"], {:goal => 'goal_2'}) # => value must be unique
     third = VectorSixteen::Experiment.pick('c_group', ["zz", "xx", "yy"], {:goal => 'goal_1'}) # => value must be unique

     VectorSixteen::Experiment.track!

     experiments = V16::RawExperiment.find_all_by_identity_id(VectorSixteen.identity)
     assert_equal 3, experiments.count
     assert_equal 2, experiments.count {|x| x.goal == 'goal_1'}
     assert_equal 3, experiments.sum_it(:conversion_value)
   end

   test "will record three different experiments with two goals but only track a conversion for goal_1" do
     VectorSixteen.identity = ActiveSupport::SecureRandom.hex(16)
     first = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"], {:goal => 'goal_1'}) # => value must be unique
     second = VectorSixteen::Experiment.pick('b_group', ["1", "2", "3"], {:goal => 'goal_2'}) # => value must be unique
     third = VectorSixteen::Experiment.pick('c_group', ["zz", "xx", "yy"], {:goal => 'goal_1'}) # => value must be unique

     VectorSixteen::Experiment.track!({:goal => 'goal_1'})

     experiments = V16::RawExperiment.find_all_by_identity_id(VectorSixteen.identity)
     assert_equal 3, experiments.count
     assert_equal 2, experiments.count {|x| x.goal == 'goal_1'}
     assert_equal 2, experiments.sum_it(:conversion_value)
   end


   test "will almost equally select each option if no weights exist" do
     a = 0
     b = 0
     c = 0
     (1..1000).each do |x|
       selected_lander = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
       case selected_lander
       when 'a' then
         a += 1
       when 'b' then
         b += 1
       when 'c' then
         c += 1
       end
     end

     nums = [] << a << b << c
     nums.sort!
     range = nums.last - nums.first

     assert (nums.first * 0.20) >= range
   end

   test "will correctly RollUp daily data" do
     # seed
     seed_raw_data(100)

     # rollup
     VectorSixteen::RollUp.process

     # do some checks
     assert V16::DailyExperiment.count > 2
     assert V16::DailyExperiment.all.detect {|x| x.conversions > 0}
     assert V16::DailyExperiment.all.detect {|x| x.views > 0}
     assert V16::DailyExperiment.all.detect {|x| x.conversion_value > 0}
   end

   test "will correctly populate weighting table" do
     # seed
     seed_raw_data(100)

     # rollup
     VectorSixteen::RollUp.process

     # compute weights
     VectorSixteen::Weights.compute
   end

   test "will populate the weighting table with equal weights if all new options are launched" do
     wipe
     seed_raw_data(100, 7)

     # rollup
     VectorSixteen::RollUp.process

     # compute weights
     VectorSixteen::Weights.compute

     # this makes the following assumptions:
     # MINIMUM_LAUNCH_DAYS = 7
     # each weight will be equal to 0.18
     assert_equal 0.54, V16::WeightedExperiment.all.sum_it(:weight).to_f
   end

   test "will populate the weighting table with different weights" do
     wipe
     seed_raw_data(100, 14)

     # rollup
     VectorSixteen::RollUp.process

     # compute weights
     VectorSixteen::Weights.compute

     # if this DOES NOT work then each weight will be equal to 0.18
     assert_not_equal 0.54, V16::WeightedExperiment.all.sum_it(:weight).to_f
   end

   test "will record the new weights in the weight history table in database" do
     wipe
     seed_raw_data(100, 14)

     # rollup
     VectorSixteen::RollUp.process

     # compute weights
     VectorSixteen::Weights.compute

     assert V16::WeightHistory.count > 1
   end

   test "will correctly record the launch window in the weight histories table" do
     wipe
     seed_raw_data(10, 6)

     # rollup
     VectorSixteen::RollUp.process

     # compute weights
     VectorSixteen::Weights.compute

     # make sure that launch_window values can be detected
     assert_not_nil V16::WeightHistory.find(:all, :conditions => 'launch_window > 0')
   end

   test "will return a weight 1.25 times higher than the highest weight for a newly launched and non-recorded alernative" do
     wipe
     seed_raw_data(100, 14)

     # rollup
     VectorSixteen::RollUp.process

     # compute weights
     VectorSixteen::Weights.compute

     # get the highest weight
     max_weight = V16::WeightedExperiment.maximum(:weight)

     # pick something
     weights = VectorSixteen::Experiment.weights('a_group', ["a", "b", "c", "f"]) # => value must be unique

     assert_equal weights['f'], (max_weight * 1.25)
   end

   private

   def wipe
     V16::DailyExperiment.delete_all
     V16::RawExperiment.delete_all
     V16::WeightedExperiment.delete_all
     V16::WeightHistory.delete_all
   end

   def seed_raw_data(num, days_ago=14)
     # seed the raw data
     (1..num).each do |x|
       VectorSixteen.identity = ActiveSupport::SecureRandom.hex(16)

       options = {:created_at => rand(days_ago).days.ago}
       options.merge!({:conversion_value => rand(100)}) if rand() < 0.20 # => convert 20% of traffic
       selected_lander = VectorSixteen::Experiment.pick('a_group', ["a", "b", "c"], options) # => value must be unique
     end
   end
end
