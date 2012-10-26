require 'spec_helper'
require 'debugger'

describe Conductor::Experiment::Weight do

  before(:each) do
    Conductor.cache.clear
    wipe
  end

  describe 'populate table when selecting a value' do

    before do
      seed_raw_data(100)
      Conductor::RollUp.process
      Conductor.reset_identity
    end

    it "correctly populates the weighting table when selecting a value" do
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"])
      Conductor::Experiment::Weight.count.should eql 3
    end
  end

  describe 'populate table with equal weights' do

    before do
      seed_raw_data(100, 7)
      Conductor::RollUp.process
    end

    it "populates the weighting table with equal weights if all new options are launched" do
      # hit after rollup to populare weight table
      Conductor.reset_identity
      Conductor.equalization_period = 7
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"])

      # each weight will be equal to 0.18
      # TODO:  look into what this is really suppose to be.  Might have to do with
      # MAX_WEIGHTING_FACTOR value change from original test case
      Conductor.equalization_period.should eql 7
      Conductor::Experiment::Weight.all.sum_it(:weight).to_f.round(2).should eql 1.07
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

    it "populates the weighting table with different weights" do
      # if this DOES NOT work then each weight will be equal to 0.18
      Conductor::Experiment::Weight.all.sum_it(:weight).to_f.should_not eql 0.54
    end


    it "returns a weight 1.25 times higher than the highest weight for a newly launched and non-recorded alernative" do
      # get the highest weight
      max_weight = Conductor::Experiment::Weight.maximum(:weight)

      # pick something
      weights = Conductor::Experiment.weights('a_group', ["a", "b", "c", "f"]) # => value must be unique

      weights['f'].should eql (max_weight * 1.25)
    end

  end

end


