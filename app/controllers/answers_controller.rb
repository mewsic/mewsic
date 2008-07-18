class AnswersController < ApplicationController  

  before_filter :login_required, :only => [:create, :update]
  before_filter :redirect_unless_xhr, :only => [:top, :newest, :siblings]
  before_filter :find_answer, :only => [:show, :siblings, :update]
  before_filter :check_answer_owner, :only => :update
  before_filter :check_valid_search_string, :only => :search

  def index
    if request.xhr? && params.include?(:user_id)
      @user = User.find_from_param(params[:user_id])
      @answers = Answer.find_paginated_by_user @user, 1, :per_page => 6
      render :partial => '/users/answers'
    else
      @open_answers         = Answer.find_open_paginated   1,    :per_page => 6

      @top_answers          = Answer.find_top_paginated    1,    :per_page => 6
      @top_answers_count    = Answer.top_count

      @newest_answers       = Answer.find_newest_paginated 1,    :per_page => 6
      @newest_answers_count = Answer.newest_count

      @top_contributors     = User.find_top_answers_contributors :limit => 10
    end
  end

  def open
    @open_answers = Answer.find_open_paginated(params[:page] || 1, :per_page => 10)
    @top_contributors = User.find_top_answers_contributors :limit => 10
  end

  def show
    @has_abuse = @answer.abuses.exists? ['user_id = ?', current_user.id] if logged_in?
    @similar_answers = @answer.find_similar
    @other_answers_by_author = Answer.find_paginated_by_user @answer.user, 1, :per_page => 6, :conditions => ['answers.id != ?', @answer.id]
  end
  
  def siblings
    @other_answers_by_author = Answer.find_paginated_by_user @answer.user, params[:page].to_i, :per_page => 6, :conditions => ['answers.id != ?', @answer.id]
    render :partial => 'other_by_user'
  end

  def top
    unless %w(open top newest).include? params[:type]
      render :nothing => true, :status => :bad_request and return
    end

    method, per_page = {
      'open'   => [:find_open_paginated,  10],
      'top'    => [:find_top_paginated,    6],
      'newest' => [:find_newest_paginated, 6]
    }.fetch(params[:type])

    answers = Answer.send(method, params[:page], :per_page => per_page)
    render :partial => 'index_list', :locals => { :answers => answers, :name => params[:type] }
  end

  def create
    @answer = Answer.new(params[:answer])
    @answer.user = current_user
    if @answer.save
      flash[:notice] = 'Your question has been saved!'
      redirect_to answer_path(@answer)
    else
      flash.now[:error] = 'The body field is required'
      index
      render :action => 'index'
    end
  end
  
  def update
    unless @answer.editable?
      flash[:alert] = "You can no longer modify this question"
    else
      if @answer.update_attributes(params[:answer])
        flash[:notice] = "The question has been updated"
      else
        flash[:error] = "The body field is required!"
      end
    end
    
    redirect_to answer_url(@answer)
  end
  
  def search
    @answers = Answer.search_paginated @q, :per_page => 5, :page => (params[:page] || 1)
    render :partial => 'search_list' and return if request.xhr?
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

protected
  def redirect_unless_xhr
    redirect_to answers_url unless request.xhr?
  end

  def find_answer
    @answer = Answer.find(params[:id], :include => :replies)
  end
  
  def check_answer_owner
    if @answer.user != current_user
      flash[:alert] = "You need to be the answer owner to update a question"
      redirect_to answer_path(@answer)
    end
  end
    
end
