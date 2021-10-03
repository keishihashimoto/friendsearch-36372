class Friend < ApplicationRecord
  # validates :friend, presence: true
  # validate :present_user?
  belongs_to :user
  
end
