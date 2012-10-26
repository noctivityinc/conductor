require 'spec_helper'

describe 'conductor' do

  it 'assigns an identity if none is specified' do
    Conductor.identity.should_not be_nil
  end

  it "selects one of the specified options randomly" do
    selected = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
    ["a", "b", "c"].should include selected
  end

  it "uses the cache if working" do
    Conductor.cache.write('testing','value')
    x = Conductor.cache.read('testing')
    x.should eql 'value'
  end

  it "allows for the equalization_period to be configurable" do
    Conductor.equalization_period = 3
    Conductor.equalization_period.should eql 3
  end

  it "raises an error if a non-numeric value, negative or 0 value is specified for the equalization_period" do
    lambda { Conductor.equalization_period = 'junk'}.should raise_exception(RuntimeError)
    lambda { Conductor.equalization_period = -1.0}.should raise_exception(RuntimeError)
    lambda { Conductor.equalization_period = 0}.should raise_exception(RuntimeError)
    lambda { Conductor.equalization_period = 3}.should_not raise_exception(RuntimeError)
  end

  it "raises an error if an improper attribute is specified for @attribute_for_weighting" do
    lambda {Conductor.attribute_for_weighting = :random}.should raise_exception(RuntimeError)
  end

  # it "select each option within 15% +/- if no weights exist" do
  #   a = 0
  #   b = 0
  #   c = 0
  #   (1..500).each do |x| 
  #     Conductor.reset_identity
  #     selected_lander = Conductor::Experiment.pick('a_group', ["a", "b", "c"]) # => value must be unique
  #     case selected_lander
  #     when 'a' then
  #       a += 1
  #     when 'b' then
  #       b += 1
  #     when 'c' then
  #       c += 1
  #     end
  #   end
 
  #   nums = [] << a << b << c
  #   nums.sort!
  #   range = nums.last - nums.first
    
  #   (nums.first * 1.15).should be >= (nums.last * 0.85)
  # end

  
end

