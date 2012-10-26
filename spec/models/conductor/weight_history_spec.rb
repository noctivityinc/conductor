require 'spec_helper'

describe Conductor::Experiment::History do

  before do
    Conductor.cache.clear
    wipe
  end

  describe 'with three options selected each time' do
    before do
      seed_raw_data(100)
      Conductor::RollUp.process

      (1..100).each do |x|
        Conductor.reset_identity
        Conductor::Experiment.pick('a_group', ["a", "b", "c"])
      end
    end

    it "pulls weights from the cache" do
      # => if this works the history table should have only been updated one time not 101 so there should
      # => be three records (one for a, b and c)
      Conductor::Experiment::History.count.should eql 3
    end
  end

  describe 'with three options selected then two optoins' do
    before do
      seed_raw_data(100)
      Conductor::RollUp.process

      (1..100).each do |x|
        Conductor.reset_identity
        Conductor::Experiment.pick('a_group', ["a", "b", "c"])
      end

      Conductor.reset_identity
      Conductor::Experiment.pick('a_group', ["a", "c"])
    end

    it "pulls weights from the cache" do
      # => if this works the history table should have only been updated one time not 101 so there should
      # => be three records (one for a, b and c)
      Conductor::Experiment::History.count.should eql 5
    end
  end

  describe 'recent data' do

    before do
      seed_raw_data(100, 14);

      # rollup
      Conductor::RollUp.process

      # hit after rollup to populare weight table
      Conductor.reset_identity
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"])
    end

    it "records the new weights in the weight history table in database" do
      Conductor::Experiment::History.count.should be > 1
    end

  end


  describe 'small amount of recent data' do

    before do
      seed_raw_data(10, 6)

      # rollup
      Conductor::RollUp.process
    end

    it "correctly records the launch window in the weight histories table" do
      # hit after rollup to populare weight table
      Conductor.reset_identity
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"])

      # make sure that launch_window values can be detected
      Conductor::Experiment::History.where('launch_window > 0').should_not be_nil
    end

  end


end
