module Admin::SongsHelper
  def mix_xml(song)
    xm = Builder::XmlMarkup.new(:indent => 2)
    xm.song {
      song.tracks.each { |track|
        xm.track :id => track.id,
          :volume => '1.0',
          :balance => '0.0',
          :filename => (track.filename.gsub(/^\/audio\//, '') rescue nil)
      }
    }
  end
end
