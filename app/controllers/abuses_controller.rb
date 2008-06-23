class AbusesController < ApplicationController
  
  layout false
  
  before_filter :login_required
  before_filter :find_abuseable

  def new
    unless request.xhr?
      redirect_to_abuseable_page
      return
    end
  end

  def create
    @abuse = Abuse.new(params[:abuse])
    @abuse.abuseable = @abuseable
    @abuse.user = current_user
    if @abuse.save
      flash.now[:notice] = 'Thank you. Your message has been saved successfully.'
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
  end
  
  def redirect_to_abuseable_page
    redirect_to send("#{@abuseable.class.name.downcase}_url", @abuseable)
  end
  
end
