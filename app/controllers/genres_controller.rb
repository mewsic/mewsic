class GenresController < ApplicationController
  def index
    @genres = Genre.find_paginated(params[:page])
    
    render :layout => false
  end
end
