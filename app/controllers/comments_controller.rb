class CommentsController < ApplicationController

  before_filter :login_required
  before_filter :find_commentable, :except => [:show, :rate]

  # ==== GET /answers/:answer_id/comments
  # ==== GET /mbands/:mband_id/comments
  # ==== GET /songs/:song_id/comments
  # ==== GET /tracks/:track_id/comments
  # ==== GET /users/:user_id/comments
  #
  def index
    @comments = @commentable.comments
  end

  # === GET /comments/:id
  #
  # Redirects the user to the detail page that contains this comment, with an anchor
  # like: "#comment-42".
  #
  def show
    @comment = Comment.find(params[:id])
    redirect_to @comment.commentable, :anchor => "comment-#{@comment.id}"
  end

  # ==== POST /answers/:answer_id/comments
  # ==== POST /mbands/:mband_id/comments
  # ==== POST /songs/:song_id/comments
  # ==== POST /tracks/:track_id/comments
  # ==== POST /users/:user_id/comments
  #
  # Creates a new comment to the given <tt>commentable</tt>, unless validations fail.
  #
  def create
    @comment = @commentable.comments.new params[:comment]
    @comment.user = current_user

    if @comment.save
      flash[:notice] = 'Your comment has been added'
    else
      flash[:error] = 'Empty comments are not allowed!'
    end

    redirect_to @commentable
  end

  # ==== PUT /comments/:id/rate
  #
  # Rates a comment, if it is rateable by the current user (see Comment#rateable_by?).
  #
  def rate
    @comment = Comment.find(params[:id])
    if @comment.rateable_by?(current_user)
      @comment.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@comment.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end

private
  def find_commentable
    @commentable =
      if params[:answer_id]
        Answer.find params[:answer_id]
      elsif params[:mband_id]
        Mband.find params[:mband_id]
      elsif params[:song_id]
        Song.find params[:song_id]
      elsif params[:track_id]
        Track.find params[:track_id]
      elsif params[:user_id]
        User.find params[:user_id]
      else
        head :bad_request
      end

    if @commentable.respond_to?(:closed?) && @commentable.closed?
      head :forbidden
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

end
