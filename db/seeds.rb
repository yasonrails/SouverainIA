# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create demo user
User.find_or_create_by!(email: 'demo@souverainia.fr') do |user|
  user.password = 'demo123'
  user.role = :admin
end

# Create sample AI model
ai_model = AiModel.find_or_create_by!(name: 'Modèle Maintenance Prédictive') do |model|
  model.description = 'Modèle IA pour la maintenance prédictive en industrie 4.0'
  model.status = :ready
  model.user = User.find_by(email: 'demo@souverainia.fr')
end

# Create sample pipeline
Pipeline.find_or_create_by!(name: 'Pipeline Fine-tuning Maintenance') do |pipeline|
  pipeline.description = 'Pipeline automatisé pour fine-tuner le modèle de maintenance'
  pipeline.status = :completed
  pipeline.user = User.find_by(email: 'demo@souverainia.fr')
  pipeline.ai_model = ai_model
end
