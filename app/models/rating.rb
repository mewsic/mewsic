# == Schema Information
# Schema version: 20090312174538
#
# Table name: ratings
#
#  id         :integer(4)    not null, primary key
#  rater_id   :integer(4)    
#  rated_id   :integer(4)    
#  rated_type :string(255)   
#  rating     :decimal(10, 2 
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
#
# == Schema Information
#
# Table name: ratings
#
#  id         :integer(11)   not null, primary key
#  rater_id   :integer(11)   
#  rated_id   :integer(11)   
#  rated_type :string(255)   
#  rating     :decimal(10, 2 
#
# == Description
#
# This model is used by the <tt>medlar_acts_as_rated</tt> plugin, that
# implements model rating.
# See https://ulisse.adelao.it/rdoc/myousica/plugins/medlar_acts_as_rated for details.
#
# == Associations
# 
# Belongs to a <tt>rated</tt>, polymorphic object and to a <tt>rater</tt>, which is a
# User instance.
#
class Rating < ActiveRecord::Base
  belongs_to :rated, :polymorphic => true
  belongs_to :rater, :class_name => 'User', :foreign_key => :rater_id
end
