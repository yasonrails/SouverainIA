class Api::V1::PipelinesController < ApplicationController
  def index
    @pipelines = Pipeline.all
    render json: @pipelines.as_json(include: [:user, :ai_model])
  end

  def show
    @pipeline = Pipeline.find(params[:id])
    render json: @pipeline.as_json(include: [:user, :ai_model])
  end
end