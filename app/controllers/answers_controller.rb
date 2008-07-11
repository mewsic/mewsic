class AnswersController < ApplicationController  
  
  before_filter :login_required, :only => [:create, :update]
  
  def index
    if request.xhr? && params.include?(:user_id)
      @user = User.find_from_param(params[:user_id])
      @answers = @user.answers.paginate(:page => params[:page], :per_page => 6, :order => 'created_at DESC')  
      render :partial => '/users/answers'
    else
      @open_answers = Answer.paginate(:per_page => 4, :page => 1, :conditions => ["answers.closed = ?", false], :include => {:user => :avatars}, :order => 'answers.created_at DESC')
      @top_answers = Answer.paginate(:per_page => 6, :page => 1, :include => {:user => :avatars}, :order => 'answers.replies_count DESC')
      @newest_answers = Answer.paginate(:per_page => 6, :page => 1, :include => {:user => :avatars}, :order => 'answers.created_at DESC')
      @top_contributors = User.find(:all, :include => [:avatars], :limit => 10, :order => 'users.replies_count DESC')
    end
  end
  
  def top
    @top_answers = Answer.paginate(:per_page => 6, :page => params[:page], :include => {:user => :avatars}, :order => 'answers.replies_count DESC')
    if request.xhr?
      render :partial => 'top', :locals => { :answers => @top_answers }
    else
      redirect_to answers_url
    end
  end
  
  def newest
    @newest_answers = Answer.paginate(:per_page => 6, :page => params[:page], :include => {:user => :avatars}, :order => 'answers.created_at DESC')
    if request.xhr?
      render :partial => 'newest', :locals => { :answers => @newest_answers }
    else
      redirect_to answers_url
    end
  end

  def show
    @answer = Answer.find(params[:id], :include => [:replies])
    if logged_in?
      @has_abuse = Abuse.exists?(["abuseable_type = 'Answer' AND abuseable_id = ? AND user_id = ?", @answer.id, current_user.id])
    end
    @other_answers_by_author = @answer.user.answers.paginate(:per_page => 6, :page => 1, :conditions => ['answers.id != ?', @answer.id])
    @similar_answers = Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.created_at DESC')
  end
  
  def siblings
    @answer = Answer.find(params[:id])
    @other_answers_by_author = @answer.user.answers.paginate(:per_page => 6, :page => params[:page], :conditions => ['answers.id != ?', @answer.id])
    if request.xhr?
      render :partial => 'other_answers_by_author', :locals => { :other_answers_by_author => @other_answers_by_author, :user => @answer.user }
    else
      redirect_to answer_url(@answer)
    end
  end
  
  def open
    @answers = Answer.paginate(:page => params[:page], :per_page => 10, :conditions => ["answers.closed = ?", false], :include => {:user => :avatars}, :order => 'answers.created_at DESC')
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
    if @answer.rateable_by?(current_user)
      @answer.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@answer.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end
    
end
