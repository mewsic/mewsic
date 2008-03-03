module SongsHelper
  
  def song_mlab_button(song)
    %|
    <a href="#" class="button mlab song add">
      <img src="/images/button_mlab.png" alt="" id="#{song.id}"/>
    </a>
    |
  end
  
end
