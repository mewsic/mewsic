# == Schema Information
# Schema version: 46
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

class HelpPage < ActiveRecord::Base
  xss_terminate :except => [:title, :body]
  
  acts_as_list
  
  validates_presence_of :title, :body

  def to_param
    self.url
  end

  def to_breadcrumb
    self.title
  end

  def self.find_from_param(param)
    if param.to_i > 0
      find(param)
    else
      find_by_url(param) or raise ActiveRecord::RecordNotFound, "Cannot find '#{param}' help page"
    end
  end
  
end
