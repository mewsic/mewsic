# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: abuses
#
#  id             :integer(11)   not null, primary key
#  abuseable_id   :integer(11)   
#  abuseable_type :string(255)   
#  user_id        :integer(11)   
#  body           :text          
#  created_at     :datetime      
#  updated_at     :datetime      
#  topic          :string(255)   
#
# == Description
#
# This model represents an abuse report for an abuseable object (currently Song, Track,
# Answer and User).
#
# <tt>body</tt> is optional and contains user-provided comments, while <tt>topic</tt> is
# required and is selected by the user when reporting the abuse.
#
# == Associations
#
# * <b>belongs_to</b> an User, the reporter of the Abuse.
# * <b>belongs_to</b> a polymorphic abuseable object.
#
class Abuse < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :abuseable, :polymorphic => true
  
end
