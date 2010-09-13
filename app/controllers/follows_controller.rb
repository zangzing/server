class FollowsController < ApplicationController
  before_filter :login_required

  def new
    @users = User.find(:all)
    @follow = Follow.new()
    render :layout => false
  end

  def create
    unless params[:follow] && params[:follow][:followed_id] 
      render :text => "Request does not contain follower or followed_id",
             :status=>400 and return
    end
    followed = User.find_by_id( params[:follow][:followed_id]);
    unless followed
         render :text => "Could not find user to follow.", :status=>500 and return
    end
    f = Follow.factory( current_user, followed );
    unless f.save
        render :text => "Could not save follower relationship", :status=>500 and return
    end
    render :text => "Follower relationship setup!", :status => 200 and return
  end

  def index
    render :json => '{ "follows" : '+current_user.follows.to_json( :only => [:followed_id,:blocked])+
            ','+'"followers" : '+current_user.followers.to_json( :only => [:follower_id,:blocked])+'}' and return
    #@followers = current_user.followers
    #@follows   = current_user.follows
    #render :layout => false
  end

  def block
     render :text => "No id of follow to block.", :status=>400 and return unless params[:id]
    # Only the followed can block a follow. The current user must be the followed to block
    follow = Follow.find( params[:id])
    render :text => "Follow with id #{params[:id]} not found", :status=>400 and return unless follow
    render :text => "Only followed can block a follow", :status=>400 and return unless follow.followed_id == current_user.id  
    follow.block
    render :text => "Follower Blocked", :status =>200 and return
  end

  def unblock
    render :text => "No id of follow to unblock.", :status=>400 and return unless params[:id]
    # Only the followed can unblock a follow. The current user must be the followed to block
    follow = Follow.find( params[:id])
    render :text => "Follow with id #{params[:id]} not found", :status=>400 and return unless follow
    render :text => "Only followed can unblock a follow", :status=>400 and return unless follow.followed_id == current_user.id
    follow.unblock
    render :text => "Follower Unblocked", :status =>200 and return
  end

  def unfollow
   render :text => "No id of follow to unfollow.", :status=>400 and return unless params[:id]
    # Only the follower can delete a follow. The current user must be the follower to delete
    follow = Follow.find( params[:id])
    render :text => "Follow with id #{params[:id]} not found", :status=>400 and return unless follow
    render :text => "Only follower can unfollow a user", :status=>400 and return unless follow.follower_id == current_user.id
    follow.destroy
    render :text => "User unfollowed", :status =>200 and return
  end  
end
