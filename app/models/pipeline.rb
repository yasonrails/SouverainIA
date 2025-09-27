class Pipeline < ApplicationRecord
  belongs_to :ai_model
  belongs_to :user

  enum status: { pending: 0, running: 1, completed: 2, failed: 3 }, _default: :pending

  has_many_attached :data_files
end
