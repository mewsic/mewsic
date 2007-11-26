class DashboardController < ApplicationController
  
  def index
    @people = User.find :random, :limit => 6
    @answers = Answer.find :all, :order => 'answers.created_at DESC', :limit => 2, :include => [:replies, :user]
  end
  
end
