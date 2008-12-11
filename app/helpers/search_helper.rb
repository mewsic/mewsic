module SearchHelper
  
  def highlight_search(text)
    q = URI.decode(@q).gsub('+', ' ').gsub('\*', '')
    text.to_s.gsub /#{q}/i, '<strong>\&</strong>'
  end
  
end
