# == Schema Information
# Schema version: 21
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
  
  acts_as_list
  
  validates_presence_of :title, :body
  
end
