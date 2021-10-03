class UsersController < ApplicationController
  before_action :set_user, only: [:show, :destroy]
  def index
    @users = User.all
  end

  def show
    @firend_ids = []
    @user.friends.each do |friend|
      @firend_ids << friend.friend
    end

    render json: {
      "id": @user.id,
      "name": @user.name,
      "friends": @firend_ids
    }    
  end

  def new
    @user_friend = UserFriend.new
  end

  def create
    @user_friend = UserFriend.new(user_params)
    if @user_friend.valid?
      @user_friend.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def user_params
    params.require(:user_friend).permit(:name, friends: [])
  end

  def set_user
    @user = User.find(params[:id])
  end

end
