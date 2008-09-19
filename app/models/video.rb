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

end
