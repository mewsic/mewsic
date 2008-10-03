# Myousica Answers controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
# 
# == Description
#
# This RESTful controller implements the <tt>/answers</tt> sections on the site, where users can engage
# in public discussion.
#
# Login is required to +create+ and +update+ an +Answer+.

class AnswersController < ApplicationController  

  before_filter :login_required, :only => [:create, :update]
  before_filter :redirect_unless_xhr, :only => [:top, :siblings]
  before_filter :find_answer, :only => [:show, :siblings, :update]
  before_filter :check_answer_owner, :only => :update
  before_filter :check_valid_search_string, :only => :search

  # <tt>GET /answers</tt>
  #
  # The index page contains listings of open, top and newest answers, along with a list of
  # top contributors. Top and newest answers are shown in paginated tabs, updated by the
  # +top+ method.
  #
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

  # <tt>GET /answers/open</tt>
  #
  # This action shows a listing of open questions and a list of top contributors.
  #
  def open
    @open_answers = Answer.find_open_paginated(params[:page] || 1, :per_page => 10)
    @top_contributors = User.find_top_answers_contributors :limit => 10
  end

  # <tt>GET /answers/:id</tt>
  #
  # Action to show an answer, along with similar ones (see Answer#find_similar for details).
  #
  def show
    @has_abuse = @answer.abuses.exists? ['user_id = ?', current_user.id] if logged_in?
    @similar_answers = @answer.find_similar 11
    @other_answers_by_author = Answer.find_paginated_by_user @answer.user, 1, :per_page => 6, :conditions => ['answers.id != ?', @answer.id]
  end
  
  # <tt>XHR GET /answers/:id/siblings</tt>
  # Action called via XHR to paginate an user's answers, used in the "more by user" in the AnswersController#show action.
  #
  def siblings
    @other_answers_by_author = Answer.find_paginated_by_user @answer.user, params[:page].to_i, :per_page => 6, :conditions => ['answers.id != ?', @answer.id]
    render :partial => 'other_by_user'

  rescue WillPaginate::InvalidPage
    render :nothing => true, :status => :bad_request
  end

  # <tt>XHR GET /answers/top?type=[open|top|newest]</tt>
  #
  # Action called via XHR to paginate and render open, top and newest answers. params[:type] contains
  # which kind of index to fetch.
  #
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

  # <tt>GET /answers/rss.xml</tt>
  #
  # Generates an RSS feed of the 20 newest answers
  #
  def rss
    @answers = Answer.find_newest_paginated 1, :per_page => 20

    respond_to do |format|
      format.xml
    end
  end

  # <tt>POST /answers</tt>
  #
  # Creates a new answer.
  #
  # FIXME: validation should be handled better (see also the +update+ action).
  #
  def create
    @answer = Answer.new(params[:answer])
    @answer.user = current_user
    if @answer.save
      flash[:notice] = 'Your question has been saved!'
      redirect_to answer_path(@answer)
    else
      flash.now[:error] = 'The body field is required!'
      index
      render :action => 'index'
    end
  end
  
  # <tt>PUT /answers/:id</tt>
  #
  # Updates an existing answer, as long as Answer#editable? allows it.
  #
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
  
  # <tt>GET /answers/search?q=search+string[&page=X]</tt>
  # <tt>XHR GET /answers/search?q=search+string[&page=X]</tt>
  #
  # Searches through the answers using the supplied query string. User input is validated by the +check_valid_search_string+
  # method. Requests coming through XHR are for pagination purposes.
  #
  def search
    @answers = Answer.search(@q, :per_page => 10, :page => params[:page] || 1, :index => 'answers', :match_mode => :boolean)

    render :partial => 'search_list' and return if request.xhr?
  end
  
  # <tt>XHR PUT /answers/:id/rate</tt>
  #
  # Rates an answer, as long as Answer#rateable_by? returns true. If this answer is not rateable by the current user, nothing
  # is rendered with a 400 status.
  #
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
  # Filter to redirect back to answers_url unless the request comes from XHR
  #
  def redirect_unless_xhr
    redirect_to answers_url unless request.xhr?
  end

  # Filter to find an answer whose id is passed in params[:id]
  #
  def find_answer
    @answer = Answer.find(params[:id], :include => :replies)
  end
  
  # Filter that checks ownership of an answer
  #
  def check_answer_owner
    if @answer.user != current_user
      flash[:alert] = "You need to be the answer owner to update a question"
      redirect_to answer_path(@answer)
    end
  end

  # Filter that checks for a valid search string.
  #
  def check_valid_search_string
    @q = CGI::unescape(params[:q] || params[:id] || '')
    @q.gsub! /[%_]/, ''

    if @q.strip.blank?
      flash[:error] = 'You did not enter a search string' 
      respond_to do |format|
        format.html { redirect_to answers_path and return }
        format.xml { render :nothing => true, :status => :bad_request }
      end
    end
  end
  
end
