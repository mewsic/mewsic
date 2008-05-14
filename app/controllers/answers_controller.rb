class AnswersController < ApplicationController  
  
  before_filter :login_required, :only => :create
  
  def index
    @open_answers = Answer.find(:all, :conditions => "answers.replies_count = 0", :include => {:user => :avatars}, :limit => 10, :order => 'answers.created_at DESC')
    @top_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.replies_count DESC')
    @newest_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.created_at DESC')
    @top_contributors = User.find(:all, :include => [:avatars], :limit => 10, :order => 'users.replies_count DESC')
  end

  def show
    @answer = Answer.find(params[:id], :include => :replies)
    @similar_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.created_at DESC')
  end

  def create
    @answer = Answer.new(params[:answer])
    @answer.user = current_user
    if @answer.save
      flash[:notice] = 'Answer saved correcly'
      redirect_to :action => 'show', :id => @answer
    else
      flash.now[:error] = 'The body field is required'
      index
      render :action => 'index'
    end
  end
  
  def rate    
    @answer = Answer.find(params[:id])
    @answer.rate(params[:rate].to_i, current_user)
    render :layout => false, :text => "#{@answer.rating_count} votes"
  end
    
end
