# Nasty hack, see: http://www.ruby-forum.com/topic/129186#576193
#
TMail::HeaderField::FNAME_TO_CLASS.delete 'content-id'

# Allow few html tags to sanitize()
ActionView::Base.sanitized_allowed_tags.clear
ActionView::Base.sanitized_allowed_tags = *%w(strong em b i code small address ul li abbr br a p)

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance| 
  "<span class=\"fieldWithErrors\">#{html_tag}</span><span class=\"error\"><img src=\"/images/alert_ico.gif\" alt="" /> #{[instance.error_message].flatten.first}</span>"
#  %{<div class="error-with-field">#{html} <small class="error">&bull; #{[instance.error_message].flatten.first}</small></div>}  
end
