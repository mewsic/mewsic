class ContentController < ApplicationController
  def show
    @page = StaticPage.find_from_param(params[:id])    
  end

  def to_breadcrumb_link
    ["Content", nil]
  end
end
