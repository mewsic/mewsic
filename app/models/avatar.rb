class Avatar < Picture
  has_attachment :storage => :file_system,
    :path_prefix => 'public/avatars',
    :content_type => 'image/jpeg' ,
    :thumbnails => { :icon => '30x30>', :small => '60x60>'}
end
