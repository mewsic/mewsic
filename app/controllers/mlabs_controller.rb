class MlabsController < ApplicationController
  
  before_filter :login_required
  before_filter :check_user_identity

  def index
    @songs = Song.find(:all, :include => :mlabs, :conditions => ["mlabs.user_id = ?", params[:user_id]])
    @tracks = Track.find(:all, :include => :mlabs, :conditions => ["mlabs.user_id = ?", params[:user_id]])
  end

private

  # TODO: esportare questo metodo in una libreria in modo tale da usarlo in altri controller
  
  def check_user_identity
    redirect_to('/') and return unless current_user.id == params[:user_id].to_i
  end

end
