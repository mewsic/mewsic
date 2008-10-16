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
# This model represents an user avatar. It subclasses the Picture model and uses
# <tt>attachment_fu</tt> to store image files on the file system.
#
class Avatar < Picture
  has_attachment :storage => :file_system,
    :path_prefix => 'public/avatars',
    :content_type => 'image/jpeg',
    :thumbnails => { :icon => 30, :small => 42, :medium => 58, :big => 150 },
    :processor => 'ImageScience'
end
