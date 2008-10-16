# == Schema Information
#
# Table name: videos
#
#  id          :integer(11)   not null, primary key
#  name        :string(32)    
#  description :string(255)   
#  filename    :string(64)    
#  poster      :string(64)    
#  highres     :string(64)    
#  thumb       :string(64)    
#  length      :integer(11)   
#  position    :integer(11)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Video < ActiveRecord::Base

  acts_as_list

  validates_presence_of :name, :filename, :poster, :highres

  def public_filename(method = :filename)
    method = :filename if method == :video

    unless [:filename, :poster, :highres, :thumb].include?(method)
      raise ArgumentError, "Invalid file type: #{method}"
    end

    [APPLICATION[:video_url], self.send(method)].join('/')
  end

  def to_json
    {:filename    => self.public_filename(:video),
     :poster      => self.public_filename(:poster),
     :highres     => self.public_filename(:highres),
     :length      => self.length,
     :name        => self.name,
     :description => self.description}.to_json
  end

end
