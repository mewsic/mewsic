module SearchHelper
  
  def highlight_search(text)
    q = URI.decode(params[:id]).gsub('+', ' ')
    text.to_s.gsub /#{q}/i, '<strong>\&</strong>'
  end
  
end
