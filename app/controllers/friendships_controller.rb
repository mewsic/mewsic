# Myousica Friendships Controller
#
# (C) 2008 Medlar s.r.l.
# (C) 2008 Mikamai s.r.l.
# (C) 2008 Adelao Group
# 
# == Description
#
# This RESTful controller handles +create+ and +destroy+ operations on Friendship objects,
# making users friends and breaking friendships :-).
#
# To access this controller, a logged in user is required, and it can obivously create and 
# destroy only own friendships.
# 
# One-way friendships in myousica are called "admirations", this means that any User can
# freely become an admirer of someone else. Two-way confirmed friendships are actual ones,
# instead.
#
class FriendshipsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  
  # <tt>POST /users/:user_id/friendships</tt>
  #
  # Creates a new friendship between the current user and the one passed via
  # the <tt>friend_id</tt> parameter. If the passed user is already a friend
  # of the current one, the two user become full friends. In the other case,
  # the current user becomes an admirer of the given one.
  # 
  def create    
    @friend = User.find(params[:friend_id])
    Friendship.create_or_accept(@user, @friend)    

    flash[:notice] = 
      if @user.is_friends_with?(@friend)
        "You and #{@friend.login} are now friends!"
      else
        "You are now an admirer of #{@friend.login}"
      end

    redirect_to user_path(@friend)
  end

  # <tt>DELETE /users/:user_id/friendships/:id</tt>
  #
  # Destroy or unaccept a friendship request. If the current friendship is one-way
  # (the current user is an admirer of the given one), it is destroyed. If it is
  # two-way (the users are actual friends), the given user becomes an admirer of
  # the current one.
  #
  def destroy
    @friendship = Friendship.find(params[:id])
    @friend = @friendship.friendshipped_for_me == @user ? @friendship.friendshipped_by_me : @friendship.friendshipped_for_me

    flash[:notice] =
      if @user.is_friends_with?(@friend)
        "You are no longer a friend of #{@friend.login}"
      else
        "You are no longer an admirer of #{@friend.login}"
      end

    @friendship.destroy_or_unaccept(@user)
    redirect_to user_path(@friend)

  rescue ActiveRecord::RecordNotFound
    flash[:notice] = nil
    redirect_to user_path(@user)
  end

private

  # Filter to find the current user, parameters are named using Rails conventions
  #
  def find_user
    @user = User.find_from_param(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to '/'  
  end
  
  # Filter to check the requested user is actually the current one
  #
  def check_current_user
    redirect_to '/' unless @user.id == current_user.id || current_user.is_admin?
  end    
  
end
