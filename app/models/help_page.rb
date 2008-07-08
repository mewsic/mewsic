# == Schema Information
# Schema version: 43
#
# Table name: help_pages
#
#  id         :integer(11)   not null, primary key
#  title      :string(255)   
#  body       :text          
#  position   :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class HelpPage < ActiveRecord::Base
  xss_terminate :except => [:title, :body]
  
  acts_as_list
  
  validates_presence_of :title, :body

  def to_param
    title.downcase.gsub(/\s/, '-')
  end

  def self.find_from_param(param)
    if param.to_i > 0
      find(param)
    else
      find :first, :conditions => ['title = ?', param.gsub('-', ' ')]
    end
  end
  
end
