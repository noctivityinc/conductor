# yaffle/test/core_ext_test.rb
 
require 'test_helper'
 
class CoreExtTest < Test::Unit::TestCase
  def test_calculation_of_waited_mean_exists
    assert [1,2,3,4,5].weighted_mean
  end

  def test_calculation_of_weighted_mean_is_correct
    assert_equal [1,2,3,4,5].weighted_mean, 3.6666666666666665
  end
end