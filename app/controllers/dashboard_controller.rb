class DashboardController < ApplicationController
  
  def index
    @people = User.find :random, :limit => 6, :conditions => ["activated_at IS NOT NULL"]
    @answers = Answer.find :all, :order => 'answers.created_at DESC', :limit => 2, :include => [:replies, :user]
  end
  
end
