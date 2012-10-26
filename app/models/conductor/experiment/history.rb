module Conductor
  class Experiment
    class History < ActiveRecord::Base
      self.table_name = 'conductor_weight_histories'
      
      attr_accessible :computed_at, :group_name, :option_name, :weight, :alternative, :launch_window
    end
  end
end
