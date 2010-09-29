require 'conductor/experiment'
require 'conductor/roll_up'
require 'conductor/weights'
require 'conductor/experiment/raw'
require 'conductor/experiment/daily'
require 'conductor/experiment/weight'
require 'conductor/experiment/history'
require 'conductor/controller/dashboard'

class Conductor
  MAX_WEIGHTING_FACTOR = 1.25
  MINIMUM_LAUNCH_DAYS = 7
  DBG = false

  cattr_writer :cache

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
end
