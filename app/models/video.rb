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
