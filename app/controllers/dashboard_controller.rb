class DashboardController < ApplicationController
  
  def index
    @people = User.find :random, :limit => 6, :include => :avatars, :conditions => ["activated_at IS NOT NULL"]
    @answers = Answer.find :all, :order => 'answers.created_at DESC', :limit => 2, :include => [:replies, {:user => :avatars}], :conditions => ["users.activated_at IS NOT NULL"]
  end
  
end