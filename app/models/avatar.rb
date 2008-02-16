class Avatar < Picture
  has_attachment :storage => :file_system,
    :path_prefix => 'public/avatars',
    :content_type => 'image/jpeg' ,
    :thumbnails => { :icon => '29x29>', :small => '60x60>', :medium => '150x150>'}
end