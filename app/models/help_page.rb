# == Schema Information
# Schema version: 35
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
  
end
