module GenresHelper
  
  def genres_pagination
    content = ""
    ('a'..'z').each do |c|
      if c != current_genre_char
        content << " " << link_to_remote(c,
	          :update => "genres",
						:url => formatted_genres_path(:format => 'html', :c => c), :method => :get, :loading => "$('genre_spinner').show();",
            :complete => "$('genre_spinner').hide();var mlabSlider = MlabSlider.getInstance(); if(mlabSlider) { mlabSlider.initSongButtons(true); }")
      else
        content << " " << c
      end
    end

    content    
  end
  
  def genres_pagination_next_button
    content = ''
    if current_genre_char < 'z'
      content << link_to_remote(image_tag('arrow_simple_right.png', :width => 7, :height => 9),
	          :update => "genres",
						:url =>  formatted_genres_path(:format => 'html', :c => next_genre_char), :method => :get, :loading => "$('genre_spinner').show();",
	          :complete => "$('genre_spinner').hide();var mlabSlider = MlabSlider.getInstance(); if(mlabSlider) { mlabSlider.initSongButtons(true); }")
    else
      content << image_tag('arrow_simple_right.png', :width => 7, :height => 9)
    end
    
    content
  end
  
  def genres_pagination_previous_button
    content = ''
    if current_genre_char > 'a'
      content << link_to_remote(image_tag('arrow_simple_left.png', :width => 7, :height => 9),
	          :update => "genres",
						:url =>  formatted_genres_path(:format => 'html', :c => previous_genre_char), :method => :get, :loading => "$('genre_spinner').show();",
	          :complete => "$('genre_spinner').hide();var mlabSlider = MlabSlider.getInstance(); if(mlabSlider) { mlabSlider.initSongButtons(true); }")
    else
      content << image_tag('arrow_simple_left.png', :width => 7, :height => 9)
    end
    
    content
  end
  
  def current_genre_char
    @genre_char ||= 'a'
  end
  
  def next_genre_char    
    current_genre_char.next
  end
  
  def previous_genre_char
    (current_genre_char[0].to_i - 1).chr
  end
  
end
