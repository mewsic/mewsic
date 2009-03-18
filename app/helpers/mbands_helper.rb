module MbandsHelper
  
  def current_user_mband_page?(options = {})
    logged_in? && @mband.members.include?(current_user)
  end
  
  def flag_icon(name = nil)
    name ||= rand(54) + 1
    image_tag "icons/flags/#{name}.gif", :width => '16'
  end

  def flag_list(count)
    (0..count).map { flag_icon }.join
  end

end
