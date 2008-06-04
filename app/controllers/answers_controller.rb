class AnswersController < ApplicationController  
  
  before_filter :login_required, :only => [:create, :update]
  
  def index
    if request.xhr? && params.include?(:user_id)
      @user = User.find_from_param(params[:user_id])
      @answers = @user.answers.paginate(:page => params[:page], :per_page => 6, :order => 'created_at DESC')  
      render :partial => '/users/answers'
    else
      @open_answers = Answer.find(:all, :conditions => "answers.replies_count = 0", :include => {:user => :avatars}, :limit => 4, :order => 'answers.created_at DESC')
      @top_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 8, :order => 'answers.replies_count DESC')
      @newest_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 8, :order => 'answers.created_at DESC')
      @top_contributors = User.find(:all, :include => [:avatars], :limit => 10, :order => 'users.replies_count DESC')
    end
  end

  def show
    @answer = Answer.find(params[:id], :include => :replies)
    @other_answers_by_author = @answer.user.answers.find(:all, :conditions => ['answers.id != ?', @answer.id], :limit => 6)
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
  
  def update
    @answer = Answer.find(params[:id])
    if @answer.user == current_user
      if @answer.created_at > 10.minutes.ago
        if @answer.update_attributes(params[:answer])
          flash[:notice] = "Answer has been updated correctly"
        else
          flash[:error] = "The body field is required"
        end
      else
        flash[:alert] = "You can no longer modify this answer"
      end
    else
      flash[:alert] = "You need to be the answer owner to update an answer"      
    end
    
    redirect_to answer_url(@answer)
  end
  
  def search
    redirect_to answers_url and return if params[:q].blank?
    @q = CGI::unescape(params[:q])    
    @answers = Answer.paginate(:all, :per_page => 5, :page => params[:page], :conditions => ["answers.body LIKE ?", "%#{@q}%"], :include => {:user => :avatars}, :order => 'answers.created_at DESC')
  end
  
  def rate    
    @answer = Answer.find(params[:id])
    @answer.rate(params[:rate].to_i, current_user)
    render :layout => false, :text => "#{@answer.rating_count} votes"
  end
    
end
