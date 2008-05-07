class AnswersController < ApplicationController  
  
  before_filter :login_required, :only => :create
  
  def index
    @open_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.created_at DESC')
    @nice_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.created_at DESC')
    @newest_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.created_at DESC')
    @top_contributors = User.find(:all, :conditions => ["1"], :include => [:replies, :avatars], :limit => 10)
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
end
