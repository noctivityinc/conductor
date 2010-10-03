require 'conductor/experiment'
require 'conductor/roll_up'
require 'conductor/weights'
require 'conductor/experiment/raw'
require 'conductor/experiment/daily'
require 'conductor/experiment/weight'
require 'conductor/experiment/history'
require 'conductor/controller/dashboard'
require 'conductor/helpers/dashboard_helper'


class Conductor
  MAX_WEIGHTING_FACTOR = 1.25
  MINIMUM_LAUNCH_DAYS = 7
  DBG = false

  cattr_writer :cache
  cattr_writer :days_till_weighting
  
  def self.cache
    @@cache || Rails.cache
  end

  class << self
    def identity=(value)
      @conductor_identity = value
    end

    def identity
      return (@conductor_identity || ActiveSupport::SecureRandom.hex(16))
    end
    
    def minimum_launch_days
      return (@@days_till_weighting || MINIMUM_LAUNCH_DAYS)
    end
    
    def attribute_for_weighting=(value)
      raise "Conductor.attribute_for_weighting must be either :views, :conversions or :conversion_value (default)" unless [:views, :conversions, :conversion_value].include?(value) 
      @attribute_for_weighting = value
    end
    
    def attribute_for_weighting
      return (@attribute_for_weighting || :conversion_value)
    end

    def log(msg)
      puts msg if DBG
    end

    def sanitize(str)
      str.gsub(/\s/,'_').downcase
    end
  end

end


class Array
  def sum_it(attribute)
    self.map {|x| x.send(attribute) }.compact.sum
  end

  def weighted_mean_of_attribute(attribute)
    self.map {|x| x.send(attribute) }.compact.weighted_mean
  end

  def weighted_mean
    w_sum = sum(self)
    return 0.00 if w_sum == 0.00
    
    w_prod = 0
    self.each_index {|i| w_prod += (i+1) * self[i].to_f}
    w_prod.to_f / w_sum.to_f
  end
end
