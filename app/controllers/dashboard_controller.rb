class DashboardController < ApplicationController
  
  before_filter :redirect_unless_xhr, :only => :top
  session :off, :only => :noop
  
  def index
    @people = User.find_top_myousicians :limit => 6
    @vat = true
  end

  def top
    @people = User.find_top_myousicians :limit => 6 #.sort_by{rand}.slice(0, 6).sort{|a,b|b.tracks_count.to_i <=> a.tracks_count.to_i}
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
  
end
