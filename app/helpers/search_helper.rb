module SearchHelper
  
  def highlight_search(text)
    q = params[:id]
    text.to_s.gsub /#{q}/i, "<strong>#{q}</strong>"
  end
  
end
