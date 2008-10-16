# Myousica Content Controller
#
# Copyright:: (C) 2008 Adelao Group
# 
# Super-simple controller to show static content pages
#
class ContentController < ApplicationController
  # ==== GET /content/:id
  #
  # Shows a static page.
  #
  def show
    @page = StaticPage.find_from_param(params[:id])    
  end

  # Generates the breadcrumb link, see ApplicationHelper#breadcrumb for more information.
  #
  def to_breadcrumb_link
    ["Content", nil]
  end
end
