module MlabsHelper
  
  def mlab_button(mixable, options = {})    
    @@mlab_item_index ||= 0
    @@mlab_item_index += 1
    options = {:dynamic => false}.merge(options)
    html_class = 'button mlab add ' << mixable.class.name.downcase
    html_class += ' dynamic' if options[:dynamic]
    html_class += ' c' if logged_in?

    image_tag 'button_mlab.png', :class => html_class, :size => '23x15',
      :onclick => "MlabSlider.instance.add#{mixable.class.name}(this);",
      :id => "#{mixable.id}_#{Time.now.to_i}_#{@@mlab_item_index}"
  end
  
end
