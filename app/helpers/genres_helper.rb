module GenresHelper
  
  def genres_pagination
    content = ""

    ('A'..'Z').each do |c|
      if c != current_genre_char
        content << ' ' << link_to(c, {}, :rel => c)
      else
        content << " " << c
      end
    end

    content    
  end
  
  def genres_pagination_next_button
    display = current_genre_char < 'Z' ? 'inline' : 'none'
    link_to image_tag('arrow_simple_right.png', :size => '7x9'), {}, :rel => next_genre_char, :class => 'next-genre', :style => "display: #{display}"
  end
  
  def genres_pagination_previous_button
    display = current_genre_char > 'A' ? 'inline' : 'none'
    link_to image_tag('arrow_simple_left.png', :size => '7x9'), {}, :rel => previous_genre_char, :class => 'prev-genre', :style => "display: #{display}"
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
