class AnswersController < ApplicationController  
  
  before_filter :login_required, :only => :create
  
  def index
    @answers = Answer.find(:all, :include => :user, :limit => 10, :order => 'answers.created_at DESC')
  end

  def show
    @answer = Answer.find(params[:id], :include => :replies)
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
