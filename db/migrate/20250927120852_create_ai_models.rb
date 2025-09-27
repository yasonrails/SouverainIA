class CreateAiModels < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_models do |t|
      t.string :name
      t.text :description
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
