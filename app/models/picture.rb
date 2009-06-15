# == Schema Information
# Schema version: 20090615124539
#
# Table name: pictures
#
#  id               :integer(4)    not null, primary key
#  pictureable_id   :integer(4)    
#  pictureable_type :string(255)   
#  type             :string(255)   
#  size             :integer(4)    
#  content_type     :string(255)   
#  filename         :string(255)   
#  string           :string(255)   
#  thumbnail        :string(255)   
#  height           :integer(4)    
#  width            :integer(4)    
#  parent_id        :integer(4)    
#  created_at       :datetime      
#  updated_at       :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: pictures
#
#  id               :integer(11)   not null, primary key
#  pictureable_id   :integer(11)   
#  pictureable_type :string(255)   
#  type             :string(255)   
#  size             :integer(11)   
#  content_type     :string(255)   
#  filename         :string(255)   
#  string           :string(255)   
#  thumbnail        :string(255)   
#  height           :integer(11)   
#  width            :integer(11)   
#  parent_id        :integer(11)   
#  created_at       :datetime      
#  updated_at       :datetime      
#
# == Description
#
# Base class for the Avatar and Photo models. It has a polymorphic belongs_to
# association because Pictures can be associated to Users, Bands, Deejays, Band
# Members, etc.
#
# Content type is checked for inclusion in a short list (see the source).
#
class Picture < ActiveRecord::Base
  belongs_to :pictureable, :polymorphic => true
  validates_inclusion_of :content_type, :in => %w(image/jpeg image/pjpeg image/png image/gif)
end
