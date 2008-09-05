class DashboardController < ApplicationController
  
  before_filter :redirect_unless_xhr, :only => :top
  session :off, :only => :noop
  
  def index
    @people = find_top_myousicians :limit => 6
  end

  def top
    @people = find_top_myousicians(:limit => 10).sort_by{rand}.slice(0, 6).sort{|a,b|b.tracks_count.to_i <=> a.tracks_count.to_i}
    render :partial => 'myousician', :collection => @people
  end

  def noop
    if params[:id]
      render :text => params[:id].to_i
    else
      head :ok
    end
  end

  def config
    @songs = Song.find_most_collaborated :limit => 5
    respond_to { |format| format.xml }
  end

private 

  def redirect_unless_xhr
    redirect_to '/' and return unless request.xhr?
  end
  
  def find_top_myousicians(options = {})
    User.find :all, options.merge(
      :select => 'COUNT(tracks.id) AS tracks_count, users.*',
      :joins => 'INNER JOIN tracks ON tracks.user_id = users.id',
      :conditions => ["users.activated_at IS NOT NULL "], #XXX XXX AND pictures.id IS NOT NULL XXX XXX
      :order => 'tracks_count DESC, users.rating_avg DESC',
      :group => 'users.id')
  end
  
end
