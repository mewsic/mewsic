module GenresHelper
  
  def genres_pagination
    content = ""

    ('A'..'Z').each do |c|
      if c != current_genre_char
        content << ' ' << link_to(c, formatted_genres_path('html', :c => c), :class => 'genre-pagination')
      else
        content << " " << c
      end
    end

    content    
  end
  
  def genres_pagination_next_button
    if current_genre_char < 'Z'
      link_to image_tag('move_arrow_right.png'), formatted_genres_path('html', :c => next_genre_char), :class => 'genre-pagination'
    end
  end
  
  def genres_pagination_previous_button
    if current_genre_char > 'A'
      link_to image_tag('move_arrow_left.png'), formatted_genres_path('html', :c => previous_genre_char), :class => 'genre-pagination'
    end
  end
  
  def current_genre_char
    @genre_char ||= 'A'
  end
  
  def next_genre_char    
    current_genre_char.next
  end
  
  def previous_genre_char
    (current_genre_char[0].to_i - 1).chr
  end
  
end
