class DashboardController < ApplicationController
  
  def index
    @people = User.find :all, :limit => 6
  end
  
end
