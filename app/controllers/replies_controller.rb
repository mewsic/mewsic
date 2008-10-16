# Myousica Replies Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This simple controller implements the creation and rating of a +Reply+ object associated
# to an Answer. Login is required to access both the +create+ and +rate+ actions.
#
# There is no <tt>new</tt> action because the reply creation form is embedded on answers
# pages.
#
class RepliesController < ApplicationController

  before_filter :login_required

  # <tt>POST /answers/:answer_id/replies</tt>
  #
  # Creates a new reply linked to the given <tt>answer_id</tt>, unless the answer is
  # already closed (see Answer#closed?) or the model validation fails.
  #
  def create
    @answer = Answer.find(params[:answer_id])

    if @answer.closed?
      flash[:error] = 'The answer is closed'
    else
      @reply = Reply.new params[:reply]
      @reply.user = current_user
      @reply.answer = @answer

      if @reply.save
        flash[:notice] = 'Reply has been saved correctly'
      else
        flash[:error] = 'The body field is required!'
      end
    end

    redirect_to answer_url(@answer)
  end

  # <tt>PUT /replies/:id/rate</tt>
  #
  # Rates a reply, if it is rateable by the current user (see Reply#rateable_by?).
  #
  def rate
    @reply = Reply.find(params[:id])
    if @reply.rateable_by?(current_user)
      @reply.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@reply.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end

end
