class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  def index
    @users = User.all
  end

  def show
    @firends = set_user_frieds

    render json: {
      "id": @user.id,
      "name": @user.name,
      "friends": @firends
    }

  end

  def new
    @user_friend = UserFriend.new
  end

  def create
    @user_friend = UserFriend.new(user_params)
    if @user_friend.valid?
      @user_friend.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    friends = set_user_frieds
    @user_friend = UserFriend.new(name: @user.name, user_id: @user.id, friends: friends)
  end

  def update
    @user_friend = UserFriend.new(user_friend_params)
    if @user_friend.valid?
      @user_friend.update
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    Friend.where(friend: @user.id).each do |friend|
      friend.destroy
    end
    redirect_to root_path
  end

  private
  def user_params
    params.require(:user_friend).permit(:name, friends: [])
  end

  def user_friend_params
    user_params.merge(user_id: params[:id])
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_user_frieds
    @user = User.find(params[:id])
    friends = []
    @user.friends.each do |friend|
      friends << friend.friend
    end
    return friends
  end

end
