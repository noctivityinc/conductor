require 'spec_helper'

describe Conductor::Experiment::Daily do

  before(:each) do
    Conductor.cache.clear
    wipe
  end

  describe 'conductor' do
    before do
      seed_raw_data(100)
      Conductor::RollUp.process
      Conductor.reset_identity
    end

    it 'correctly rollups daily data' do
      Conductor::Experiment::Daily.count.should be > 2
      Conductor::Experiment::Daily.all.should be_any {|x| x.conversions > 0}
      Conductor::Experiment::Daily.all.should {|x| x.views > 0}
      Conductor::Experiment::Daily.all.should {|x| x.conversion_value > 0}
    end

  end

  describe 'with a lot of data over 30 days' do
    before(:each) do
      seed_raw_data(500, 30)

      # rollup
      Conductor::RollUp.process
    end

    it "correctly calculates weights even if there are no conversions" do
      Conductor::Experiment::Daily.update_all('conversion_value = 0.00, conversions = 0')
      Conductor.reset_identity

      Conductor::Experiment::Daily.all.detect {|x| x.conversions > 0 || x.conversion_value > 0}.should be_nil
      Conductor::Experiment.weights('a_group', ["a", "b", "c"]).values.sum.should eql 3
    end

    it "correctly calculates weights even if an alternative has no conversions" do
      Conductor::Experiment::Daily.update_all('conversion_value = 0.00, conversions = 0', "alternative = 'a'")
      Conductor.reset_identity

      Conductor::Experiment::Daily.find_all_by_alternative('a').detect {|x| x.conversions > 0 || x.conversion_value > 0}.should be_nil
      Conductor::Experiment.weights('a_group', ["a", "b", "c"])['a'].should eql 0
    end

    it "allows for the number of conversions to be used for weighting instead of conversion_value" do
      Conductor.reset_identity
      Conductor::Experiment.pick('a_group', ["a", "b", "c"])
      weights_cv = Conductor::Experiment::Weight.all.map(&:weight).sort

      Conductor.reset_identity
      Conductor.attribute_for_weighting = :conversions
      Conductor::Experiment.pick('a_group', ["a", "b", "c"])
      weights_c = Conductor::Experiment::Weight.all.map(&:weight).sort

      # since one is using conversion_value and the other is using conversions, they two weight arrays should be different
      Conductor.attribute_for_weighting.should eql :conversions
      weights_cv.should_not eql weights_c
    end


  end

end
