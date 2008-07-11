module GenresHelper
  
  def genres_pagination
    content = ''

    ('A'..'Z').each do |c|
      if c != current_genre_char
        if @genre_chars.include? c
          content << ' ' << link_to(c, formatted_genres_path('html', :c => c), :class => 'genre-pagination')
        else
          content << %[<span class="empty"> #{c}</span>]
        end
      else
        content << ' ' << %[<span class="current"> #{c}</span>]
      end
    end

    content    
  end
  
  def genres_pagination_next_button
    if current_genre_char != @genre_chars.last
      link_to image_tag('move_arrow_right.png'), formatted_genres_path('html', :c => next_genre_char), :class => 'genre-pagination arrow', :onclick => 'return false'
    end
  end
  
  def genres_pagination_previous_button
    if current_genre_char != @genre_chars.first
      link_to image_tag('move_arrow_left.png'), formatted_genres_path('html', :c => previous_genre_char), :class => 'genre-pagination arrow', :onclick => 'return false'
    end
  end
  
  def current_genre_char
    @genre_char ||= @genre_chars.first
  end
  
  def next_genre_char
    index = @genre_chars.index(current_genre_char) + 1
    @genre_chars[index]
  end
  
  def previous_genre_char
    index = @genre_chars.index(current_genre_char) - 1
    @genre_chars[index]
  end
  
end
