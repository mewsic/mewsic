# == Schema Information
# Schema version: 35
#
# Table name: help_requests
#
#  email :string        
#  body  :text          
#

class HelpRequest < ActiveRecord::Base
  has_no_table

  column :email, :string
  column :body, :text

  validates_presence_of :email, :body
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
