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
# This model represents a user's gallery photo. It subclasses the Picture model and
# uses the <tt>attachment_fu</tt> plugin to store image files on the file system,
# into the <tt>public/photos</tt> path.
#
# See https://ulisse.adelao.it/rdoc/myousica/plugins/attachment_fu for details on
# <tt>attachment_fu</tt>.
#
class Photo < Picture
  has_attachment :storage => :file_system,
    :path_prefix => 'public/photos',
    :content_type => 'image/jpeg' ,
    :thumbnails => { :icon => 30, :small => 60, :large => '700x700'},
    :processor => 'ImageScience'
end
