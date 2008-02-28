# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '02cedf3882e78b5a99c0bec5cc75c3fc'
  
  include AuthenticatedSystem
  
  before_filter :load_mlab_tracks
  
  protected
  
  def load_mlab_tracks
    track_ids = cookies[:mlab_tracks].to_s.split('|')
    @mlab_tracks = if !track_ids.empty? && logged_in?
      Track.find(:all, :conditions => ["id IN (#{Array.new(track_ids.size).fill('?').join(',')})", *track_ids])
    else
      cookies[:mlab_tracks] = ''
      []
    end
  end
  
  def to_breadcrumb
    controller_name
  end
end