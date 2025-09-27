class PipelinesController < ApplicationController
  def index
    @pipelines = current_user.pipelines
  end

  def show
    @pipeline = current_user.pipelines.find(params[:id])
  end

  def new
    @pipeline = current_user.pipelines.build
  end

  def create
    @pipeline = current_user.pipelines.build(pipeline_params)
    if @pipeline.save
      redirect_to @pipeline, notice: 'Pipeline créé avec succès.'
    else
      render :new
    end
  end

  def edit
    @pipeline = current_user.pipelines.find(params[:id])
  end

  def update
    @pipeline = current_user.pipelines.find(params[:id])
    if @pipeline.update(pipeline_params)
      redirect_to @pipeline, notice: 'Pipeline mis à jour.'
    else
      render :edit
    end
  end

  def destroy
    @pipeline = current_user.pipelines.find(params[:id])
    @pipeline.destroy
    redirect_to pipelines_path, notice: 'Pipeline supprimé.'
  end

  private

  def pipeline_params
    params.require(:pipeline).permit(:name, :description, :ai_model_id, data_files: [])
  end
end
