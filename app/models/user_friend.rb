class UserFriend
  include ActiveModel::Model
  attr_accessor :name, :user_id, :friends

  with_options presence: true do
    validates :name
  end

  validate :present_user?, if: :friend_selected?

  def save
    user = User.create(name: name)
    if friends != [] && friends != nil
      friends.each do |friend|
        Friend.create(user_id: user.id, friend: friend)
      end
    end
  end

  def present_user?
    friends.each do |friend|
      unless User.exists?(id: friend)
        errors.add(:friend, "selected doesn't exist.")
        break
      end
    end
  end

  def friend_selected?
    return (friends != nil && friends != [])
  end
end