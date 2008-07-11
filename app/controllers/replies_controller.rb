class RepliesController < ApplicationController
  
  before_filter :login_required
  
  def create
    @answer = Answer.find(params[:answer_id])
    
    if @answer.closed?
      flash[:error] = 'The answer is closed'
    else
      @reply = Reply.new(params[:reply])
      @reply.answer = @answer
      @reply.user = current_user
      if @reply.save
        @answer.update_replies_count
        flash[:notice] = 'Reply has been saved correctly'      
      else
        flash[:error] = 'The body field is required!'
      end
    end
    
    redirect_to answer_url(@answer)
  end
  
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
