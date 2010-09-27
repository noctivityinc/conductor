require 'conductor/experiment'
require 'conductor/roll_up'
require 'conductor/weights'
require 'conductor/experiment/raw'
require 'conductor/experiment/daily'
require 'conductor/experiment/weight'

class Conductor
  MAX_WEIGHTING_FACTOR = 1.25
  MINIMUM_LAUNCH_DAYS = 7
  DBG = false

  @@VERSION = "0.1.0"
  @@MAJOR_VERSION = "1.0"
  cattr_reader :VERSION
  cattr_reader :MAJOR_VERSION

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
  end
end


class Array
  def sum_it(attribute)
    self.map {|x| x.send(attribute) }.compact.sum
  end
end
