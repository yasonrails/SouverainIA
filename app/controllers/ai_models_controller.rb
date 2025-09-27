class AiModelsController < ApplicationController
  def index
    @ai_models = current_user.ai_models
  end

  def show
    @ai_model = current_user.ai_models.find(params[:id])
  end

  def new
    @ai_model = current_user.ai_models.build
  end

  def create
    @ai_model = current_user.ai_models.build(ai_model_params)
    if @ai_model.save
      redirect_to @ai_model, notice: 'Modèle IA créé avec succès.'
    else
      render :new
    end
  end

  def edit
    @ai_model = current_user.ai_models.find(params[:id])
  end

  def update
    @ai_model = current_user.ai_models.find(params[:id])
    if @ai_model.update(ai_model_params)
      redirect_to @ai_model, notice: 'Modèle IA mis à jour.'
    else
      render :edit
    end
  end

  def destroy
    @ai_model = current_user.ai_models.find(params[:id])
    @ai_model.destroy
    redirect_to ai_models_path, notice: 'Modèle IA supprimé.'
  end

  private

  def ai_model_params
    params.require(:ai_model).permit(:name, :description, model_files: [])
  end
end
