# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: help_pages
#
#  id         :integer(11)   not null, primary key
#  title      :string(255)   
#  body       :text          
#  position   :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#  url        :string(255)   
#
# == Description
#
# This model represents an help page. +acts_as_list+ to implement customizable 
# display ordering. As of now, no sanitization is made either on title nor on body,
# because help pages are now intended to be created from raw html using the raw
# admin interface.
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>title</tt> and <tt>body</tt>.
#
class HelpPage < ActiveRecord::Base
  xss_terminate :except => [:title, :body]

  acts_as_list

  validates_presence_of :title, :body

  # Shows the <tt>url</tt> attribute in HTTP paths.
  def to_param
    self.url
  end

  # Puts the page title into the breadcrumb.
  def to_breadcrumb
    self.title
  end

  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.6
  end

  # Finds an help page by <tt>id</tt> or <tt>url</tt>, as returned by the +to_param+ method.
  def self.find_from_param(param)
    if param.to_i > 0
      find(param)
    else
      find_by_url(param) or raise ActiveRecord::RecordNotFound, "Cannot find '#{param}' help page"
    end
  end

end
