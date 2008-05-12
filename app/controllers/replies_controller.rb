class RepliesController < ApplicationController
  
  before_filter :login_required, :only => :create
  
  def create
    @answer = Answer.find(params[:answer_id])
    @reply = Reply.new(params[:reply])
    @reply.answer = @answer
    @reply.user = current_user
    if @reply.save
      flash[:notice] = 'Reply has been save correctly.'
      redirect_to answer_url(@answer)
    else
      flash[:error] = 'The body field is required.'
      redirect_to answer_url(@answer)
    end
  end
  
  def rate    
    @reply = Reply.find(params[:id])
    @reply.rate(params[:rate].to_i, current_user)
    render :layout => false, :text => "#{@reply.rating_count} votes"
  end
  
end
