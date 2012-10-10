require_dependency "conductor/application_controller"

module Conductor
  class DashboardController < ApplicationController
    def index
        @weights = Conductor::Experiment::Weight.all
        @weight_history = Conductor::Experiment::History.all
        @dailies = Conductor::Experiment::Daily.all
      end
  end
end
