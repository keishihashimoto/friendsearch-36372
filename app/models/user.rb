class User < ApplicationRecord
  # validates :name, presence: true
  has_many :friends, dependent: :destroy
end
