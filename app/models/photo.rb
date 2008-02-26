# == Schema Information
# Schema version: 11
#
# Table name: pictures
#
#  id           :integer(11)   not null, primary key
#  user_id      :integer(11)   
#  type         :string(255)   
#  size         :integer(11)   
#  content_type :string(255)   
#  filename     :string(255)   
#  string       :string(255)   
#  thumbnail    :string(255)   
#  height       :integer(11)   
#  width        :integer(11)   
#  parent_id    :integer(11)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Photo < Picture
  has_attachment :storage => :file_system,
    :path_prefix => 'public/images/photos',
    :content_type => 'image/jpeg' ,
    :thumbnails => { :icon => '30x30', :small => '60x60'}
end
