class DashboardController < ApplicationController
  
  def index
    @people = User.find :random, :limit => 6
  end
  
end
