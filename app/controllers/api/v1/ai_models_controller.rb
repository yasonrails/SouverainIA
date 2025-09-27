class Api::V1::AiModelsController < ApplicationController
  def index
    @ai_models = AiModel.all
    render json: @ai_models.as_json(include: :user)
  end

  def show
    @ai_model = AiModel.find(params[:id])
    render json: @ai_model.as_json(include: :user)
  end
end