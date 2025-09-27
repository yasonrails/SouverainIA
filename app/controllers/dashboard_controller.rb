class DashboardController < ApplicationController
  def index
    @ai_models = current_user.ai_models
    @pipelines = current_user.pipelines
  end
end
