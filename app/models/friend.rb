class Friend < ApplicationRecord
  validates :friend, presence: true
  validate :present_user?
  belongs_to :user


  def present_user?
    unless User.exitsts?(id: friend)
      errors.add(:friend, "selected doesn't exist.")
    end
  end
end
