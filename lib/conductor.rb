require "conductor/engine"
require 'conductor/core_ext'
require 'conductor/experiment'
require 'conductor/roll_up'
require 'conductor/weights'
require 'haml'

module Conductor
  MAX_WEIGHTING_FACTOR = 1.25
  EQUALIZATION_PERIOD_DEFAULT = 7
  DBG = false

  # attr_accessor :cache

  def self.cache
    $cache || Rails.cache
  end

  class << self
    # Specifies a unique identity for the current visitor.  If no identity is specified
    # then a random value is selected.  Conductor makes sure that the same visitor
    # will always see the same alternative selections to reduce confusion.
    def identity=(value)
      @conductor_identity = value
    end

    def identity
      return (@conductor_identity || SecureRandom.hex(16))
    end

    def reset_identity
      @conductor_identity = SecureRandom.hex(16)
    end

    # The number of days to include when calculating weights
    # The inclusion period MUST be higher than then equalization period
    # The default is 14 days
    def inclusion_period=(value)
      raise "Conductor.inclusion_period must be a positive number > 0" unless value.is_a?(Numeric) && value > 0
      raise "Conductor.inclusion_period must be greater than the equalization period" if value < equalization_period
      @inclusion_period = value
    end

    def inclusion_period
      return (@inclusion_period || 14)
    end

    # The equalization period is the initial amount of time, in days, that conductor
    # should apply the max_weighting_factor towards a new alternative to ensure
    # that it receives a far shot of performing.
    #
    # If an equalization period was not used then any new alternative would
    # immediately be weighed very low since it has no conversions and would
    # never have a chance of performing
    def equalization_period=(value)
      raise "Conductor.equalization_period must be a positive number > 0" unless value.is_a?(Numeric) && value > 0
      @equalization_period = value
    end

    def equalization_period
      return (@equalization_period || EQUALIZATION_PERIOD_DEFAULT)
    end

    # The attribute for weighting specifies if the conversion_value OR number of conversions
    # should be used to calculate the weight.  The default is conversion_value.
    #
    # TODO: Allow of avg_conversion_value where acv = conversion_value / conversions
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
