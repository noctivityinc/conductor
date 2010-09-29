class Conductor
  module Controller
    module Dashboard

      ActionController::Base.view_paths.unshift File.join(File.dirname(__FILE__), "../views")
      
      def index
        @weights = Conductor::Experiment::Weight.all
        @weight_history = Conductor::Experiment::History.all
        @dailies = Conductor::Experiment::Daily.all
      end
      
    end
  end
end