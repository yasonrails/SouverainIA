class AiModel < ApplicationRecord
  belongs_to :user

  enum status: { uploaded: 0, training: 1, ready: 2, deployed: 3 }, _default: :uploaded

  has_many_attached :model_files
end
