class CreatePipelines < ActiveRecord::Migration[7.1]
  def change
    create_table :pipelines do |t|
      t.string :name
      t.text :description
      t.string :status
      t.references :ai_model, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
