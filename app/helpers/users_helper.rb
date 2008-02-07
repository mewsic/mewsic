module UsersHelper
  
  def radio_button_for_user(name, value, options = {})
    checked = params[:user] && params[:user][name.to_sym] == value.to_s ? 'checked="checked"' : ''
    _class = options.include?(:class) ? "class=\"#{options[:class]}\"" : ''
    %|<input #{checked} #{_class} id="user_#{name}_#{value}" name="user[#{name}]" type="radio" value="#{value}" />|
  end
   
  def signup_error_message
    %|<p class="alert">There were errors during the signup process, please check the fields.</p>| unless @user.errors.empty?
  end
  
  def gender_icon
    icons = {:male => 'M', :female => 'F', :other => 'O'}
    %|<img alt="" src="/images/gender_ico_#{icons[@user.gender.to_sym]}.gif"/>| unless @user.gender.blank?
  end
  
  def track_icon(track, color = nil)
    icon_color = "_#{color.to_s}" unless color.nil?
    %|<img width="29" height="29" alt="#{track.instrument}" src="/images/instrument_#{track.instrument}#{icon_color}.png"/>|
  end
   
  def current_user_page
    current_user && current_user == @user
  end
  
  def instrument_icon(instrument)
    %|<img width="29" height="29" alt="" src="/images/instrument_#{instrument}.png"/>|
  end
end