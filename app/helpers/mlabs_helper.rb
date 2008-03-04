module MlabsHelper
  
  def mlab_button(mixable)
    @@mlab_item_index ||= 0
    @@mlab_item_index += 1
    %|
    <a href="#" onclick="return false;" class="button mlab #{mixable.class.name.downcase} add">
      <img src="/images/button_mlab.png" alt="" id="#{mixable.id}_#{Time.now.to_i}_#{@@mlab_item_index}"/>
    </a>
    |
  end
  
end
