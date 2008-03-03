module TracksHelper

  def track_mlab_button(track)
    %|
    <a href="#" class="button mlab track add">
      <img src="/images/button_mlab.png" alt="" id="#{track.id}"/>
    </a>
    |
  end
  
end
