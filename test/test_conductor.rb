require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestConductor < Test::Unit::TestCase
  # Wipes cache, D/B prior to doing a test run.
  def setup
    Conductor.cache.clear
    wipe
  end

  context "conductor" do
    should "assign an identity if none is specified" do
      assert Conductor.identity != nil
    end

    should "select one of the specified options randomly" do
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
      assert ["a", "b", "c"].include? selected
    end

    should "almost equally select each option if no weights exist" do
      a = 0
      b = 0
      c = 0
      (1..1000).each do |x|
        Conductor.identity = ActiveSupport::SecureRandom.hex(16)
        selected_lander = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
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
  end

  context "a single site visitor" do
    setup do
      Conductor.identity = ActiveSupport::SecureRandom.hex(16)
    end

    should "always select the same alternative when using the cache" do
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
      different = false

      (1..100).each do |x|
        different = true if selected != Conductor::Experiment.pick('a_group', ["a", "b", "c"])
      end

      assert !different
    end

    should "select a lander and then successfully record a conversion" do
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique

      Conductor::Experiment.track!

      experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity)
      assert_equal 1, experiments.count
      assert_equal 1, experiments.first.conversion_value
    end

    should "select a lander and then successfully record custom conversion value" do
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique

      Conductor::Experiment.track!({:value => 12.34})

      experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity)
      assert_equal 1, experiments.count
      assert_equal 12.34, experiments.first.conversion_value
    end

    should "record three different experiments with two goals but a single conversion for all goals for the same identity" do
      first = Conductor::Experiment.pick('a_group', ["a", "b", "c"], {:goal => 'goal_1'}) # => value must be unique
      second = Conductor::Experiment.pick('b_group', ["1", "2", "3"], {:goal => 'goal_2'}) # => value must be unique
      third = Conductor::Experiment.pick('c_group', ["zz", "xx", "yy"], {:goal => 'goal_1'}) # => value must be unique

      Conductor::Experiment.track!

      experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity)
      assert_equal 3, experiments.count
      assert_equal 2, experiments.count {|x| x.goal == 'goal_1'}
      assert_equal 3, experiments.sum_it(:conversion_value)
    end

    should "record three different experiments with two goals but only track a conversion for goal_1" do
      first = Conductor::Experiment.pick('a_group', ["a", "b", "c"], {:goal => 'goal_1'}) # => value must be unique
      second = Conductor::Experiment.pick('b_group', ["1", "2", "3"], {:goal => 'goal_2'}) # => value must be unique
      third = Conductor::Experiment.pick('c_group', ["zz", "xx", "yy"], {:goal => 'goal_1'}) # => value must be unique

      Conductor::Experiment.track!({:goal => 'goal_1'})

      experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity)
      assert_equal 3, experiments.count
      assert_equal 2, experiments.count {|x| x.goal == 'goal_1'}
      assert_equal 2, experiments.sum_it(:conversion_value)
    end
  end

  context "conductor" do
    setup do
      seed_raw_data(100)
      Conductor::RollUp.process
    end

    should "correctly RollUp daily data" do
      assert Conductor::Experiment::Daily.count > 2
      assert Conductor::Experiment::Daily.all.detect {|x| x.conversions > 0}
      assert Conductor::Experiment::Daily.all.detect {|x| x.views > 0}
      assert Conductor::Experiment::Daily.all.detect {|x| x.conversion_value > 0}
    end

    should "correctly populate weighting table" do
      Conductor::Weights.compute
    end
  end

  context "conductor" do
    should "populate the weighting table with equal weights if all new options are launched" do
      seed_raw_data(100, 7)

      # rollup
      Conductor::RollUp.process

      # compute weights
      Conductor::Weights.compute

      # this makes the following assumptions:
      # MINIMUM_LAUNCH_DAYS = 7
      # each weight will be equal to 0.18
      assert_equal 0.54, Conductor::Experiment::Weight.all.sum_it(:weight).to_f
    end
  end

  context "conductor" do
    setup do
      seed_raw_data(100, 14);

      # rollup
      Conductor::RollUp.process

      # compute weights
      Conductor::Weights.compute
    end

    should "populate the weighting table with different weights" do
      # if this DOES NOT work then each weight will be equal to 0.18
      assert_not_equal 0.54, Conductor::Experiment::Weight.all.sum_it(:weight).to_f
    end

    should "record the new weights in the weight history table in database" do
      assert Conductor::Experiment::History.count > 1
    end

    should "return a weight 1.25 times higher than the highest weight for a newly launched and non-recorded alernative" do
      seed_raw_data(100, 14)

      # rollup
      Conductor::RollUp.process

      # compute weights
      Conductor::Weights.compute

      # get the highest weight
      max_weight = Conductor::Experiment::Weight.maximum(:weight)

      # pick something
      weights = Conductor::Experiment.weights('a_group', ["a", "b", "c", "f"]) # => value must be unique

      assert_equal weights['f'], (max_weight * 1.25)
    end
  end

  context "conductor" do
    should "correctly record the launch window in the weight histories table" do
      seed_raw_data(10, 6)

      # rollup
      Conductor::RollUp.process

      # compute weights
      Conductor::Weights.compute

      # make sure that launch_window values can be detected
      assert_not_nil Conductor::Experiment::History.find(:all, :conditions => 'launch_window > 0')
    end
  end




  private

    def wipe
      Conductor::Experiment::Daily.delete_all
      Conductor::Experiment::Raw.delete_all
      Conductor::Experiment::Weight.delete_all
      Conductor::Experiment::History.delete_all
    end

    def seed_raw_data(num, days_ago=14)
      # seed the raw data
      (1..num).each do |x|
        Conductor.identity = ActiveSupport::SecureRandom.hex(16)

        options = {:created_at => rand(days_ago).days.ago}
        options.merge!({:conversion_value => rand(100)}) if rand() < 0.20 # => convert 20% of traffic
        selected_lander = Conductor::Experiment.pick('a_group', ["a", "b", "c"], options) # => value must be unique
      end
    end
end
