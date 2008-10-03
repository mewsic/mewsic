# Myousica Abuses controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
# 
# == Description
#
# This RESTful controller handles the Abuse creation process, triggered by abuse links throughout
# the site and displayed into a <tt>Lightview</tt>.
#
# The +Abuse+ model uses a polymorphic <tt>has_many</tt> association with different models, see the
# +find_abuseable+ method for details.
#
# Login is required in order to create new abuses.
#
class AbusesController < ApplicationController
  
  layout false
  
  before_filter :login_required
  before_filter :find_abuseable  

  # <tt>GET /abuses/new</tt>
  #
  # Show the abuse creation form if an abuse for the current object does not exist.
  # If it exists, the view renders "Notification already sent".
  #
  # This view is rendered inside a <tt>Lightview</tt>
  #
  def new    
  end

  # <tt>POST /abuses/create</tt>
  #
  # Create a new abuse if it does not exist, show a notification if it does.
  # Upon creation, a notification is sent to abuse@myousica.com with object
  # details (see <tt>app/views/abuse_mailer/notification.erb</tt>) and user
  # supplied message.
  #
  # This view closes the <tt>Lightview</tt> and shows the flash contents using
  # the Message Javascript object (see <tt>public/javascripts/flash.js</tt>).
  #
  def create
    @abuse = Abuse.new(params[:abuse])
    @abuse.abuseable = @abuseable
    @abuse.user = current_user
    if @exists
      render :action => 'new'      
    elsif @abuse.save
      flash.now[:notice] = 'Thank you. Your message has been saved successfully.'
      mail = AbuseMailer.create_notification(@abuseable, @abuse, current_user)
      AbuseMailer.deliver(mail)
    else
      flash.now[:error] = 'Error saving the message. Please try again.'      
    end
  end

private

  # Find the abuseable, using Rails parameter name conventions. The models that
  # currently have got the polymorphic <tt>has_many</tt> association are: +Answer+,
  # +Song+, +Track+ and +User+.
  # 
  # This method also checks if an abuse for the requested object exists and saves
  # the result in the <tt>@exist</tt> instance variable.
  #
  # If no abuseable is found, nothing is rendered with a 404 status.
  #
  def find_abuseable
    @abuseable = if params.include?(:answer_id)
      Answer.find(params[:answer_id])
    elsif params.include?(:song_id)
      Song.find(params[:song_id])
    elsif params.include?(:track_id)
      Track.find(params[:track_id])
    elsif params.include?(:user_id)
      User.find_from_param(params[:user_id])
    else
      raise ActiveRecord::RecordNotFound
    end 
    @exists = Abuse.exists?(["abuseable_type = ? AND abuseable_id = ?", @abuseable.class.name, @abuseable.id])

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found
  end
  
end
