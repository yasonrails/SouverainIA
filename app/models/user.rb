class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { user: 0, manager: 1, admin: 2 }, _default: :user

  has_many :ai_models, dependent: :destroy
  has_many :pipelines, dependent: :destroy
end
