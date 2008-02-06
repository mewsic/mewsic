module UsersHelper
  
  def radio_button_for_user(name, value, options = {})
    checked = params[:user] && params[:user][name.to_sym] == value.to_s ? 'checked="checked"' : ''
    _class = options.include?(:class) ? "class=\"#{options[:class]}\"" : ''
    %|<input #{checked} #{_class} id="user_#{name}_#{value}" name="user[#{name}]" type="radio" value="#{value}" />|
  end
   
  def signup_error_message
    %|<p class="alert">There were errors during the signup process, please check the fields.</p>| unless @user.errors.empty?
  end
  
end