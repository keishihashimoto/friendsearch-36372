class UserFriend
  include ActiveModel::Model
  attr_accessor :name, :user_id, :friends

  with_options presence: true do
    validates :name
  end

  validate :present_user?, if: :friend_selected?
  validate :identical?, if: :friend_selected?

  def save
    user = User.create(name: name)
    if friends != [] && friends != nil
      friends.each do |friend|
        Friend.create(user_id: user.id, friend: friend)
      end
    end
  end

  def update
    User.find(user_id).update(name: name)
    if friends != nil && friends != []
      friends.each do |friend|
        Friend.where(user_id: user_id, friend: friend).first_or_create
      end
    end
    if Friend.where(user_id: user_id) != nil
      Friend.where(user_id: user_id).each do |friend_of_user|
        unless friends.include?(friend_of_user.friend.to_s)
          friend_of_user.destroy
        end
      end
    end
  end


  def present_user?
    friends.each do |friend|
      unless User.exists?(id: friend)
        errors.add(:firends, "selected doesn't exist.")
        break
      end
    end
  end

  def identical?
    friends.each do |friend|
      if friend == user_id
        errors.add(:friends, "you're selecting is yourself.")
        break
      end
    end
  end

  def friend_selected?
    return (friends != nil && friends != [])
  end
end