class AbusesController < ApplicationController
  
  layout false
  
  before_filter :login_required
  before_filter :find_abuseable  

  def new    
  end

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

  def find_abuseable
    @abuseable = if params.include?(:answer_id)
      Answer.find(params[:answer_id])
    elsif params.include?(:song_id)
      Song.find(params[:song_id])
    else
      raise ActiveRecord::RecordNotFound
    end 
    @exists = Abuse.exists?(["abuseable_type = ? AND abuseable_id = ?", @abuseable.class.name, @abuseable.id])

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :bad_request
  end
  
  def redirect_to_abuseable_page
    redirect_to send("#{@abuseable.class.name.downcase}_url", @abuseable)
  end
  
end
