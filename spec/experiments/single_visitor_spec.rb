require 'spec_helper'
require 'debugger'


describe 'a single site visitor', :caching => true do

  before do
    Conductor.reset_identity
  end

  it "always selects the same alternative when using the cache" do
    last_selected = nil
    different = false

    (1..100).each do |x|
      selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"])
      different = true if last_selected && selected != last_selected
      last_selected = selected
    end

    different.should be_false
  end
end

describe 'a single site visitor with a tracked selection' do

  before do
    Conductor.reset_identity
    selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
  end

  it "successfully records a conversion" do
    Conductor::Experiment.track!
    experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity.to_s)
    experiments.count.should eql 1
    experiments.first.conversion_value.to_f.should eql 1.0
  end

  it "successfully records a conversion with a custom value" do
    Conductor::Experiment.track!({:value => 12.34})
    experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity.to_s)
    experiments.count.should eql 1
    experiments.first.conversion_value.should eql 12.34
  end

end

describe 'a single site visitor with three different selections' do

  before do
    Conductor.reset_identity
    first = Conductor::Experiment.pick('a_group', ["a", "b", "c"], {:goal => 'goal_1'}) # => value must be unique
    second = Conductor::Experiment.pick('b_group', ["1", "2", "3"], {:goal => 'goal_2'}) # => value must be unique
    third = Conductor::Experiment.pick('c_group', ["zz", "xx", "yy"], {:goal => 'goal_1'}) # => value must be unique
  end

  it "successfully records a conversion" do
    Conductor::Experiment.track!
    experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity.to_s)
    experiments.count.should eql 3
    experiments.count {|x| x.goal == 'goal_1'}.should eql 2
    experiments.sum_it(:conversion_value).should eql 3
  end

  it "successfully records a conversion for goal_1 only" do
    Conductor::Experiment.track!({:goal => 'goal_1'})
    experiments = Conductor::Experiment::Raw.find_all_by_identity_id(Conductor.identity.to_s)
    experiments.count.should eql 3
    experiments.count {|x| x.goal == 'goal_1'}.should eql 2
    experiments.sum_it(:conversion_value).should eql 2
  end

  
end
