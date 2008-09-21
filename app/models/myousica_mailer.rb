class MyousicaMailer < ActionMailer::Base

  def help_request(request, sent_at = Time.now)
    @subject    = 'Myousica Help Question'
    @body       = request.body
    @recipients = 'help@myousica.com'
    @from       = request.email
    @sent_on    = sent_at
    @headers    = {}
  end

  def new_user_notification(user)
    @subject    = "New user registration: #{user.login}"
    @body       = <<-EOF
Login  : #{user.login}
Email  : #{user.email}
Country: #{user.country}
City   : #{user.city}
Name   : #{user.first_name} #{user.last_name}

#{APPLICATION[:url]}#{user_path(user)}
    EOF
    @recipients = 'activity@myousica.com'
    @from       = 'register@myousica.com'
  end

  def new_track_notification(track)
    @subject    = "New track created: #{track.title}"
    @body       = <<-EOF
Title : #{track.title}
Descr.: #{track.description}
User  : #{track.user.login rescue nil}
Tone  : #{track.tonality}
Length: #{track.length}
Genre : #{track.genre}

#{APPLICATION[:url]}#{track.public_filename}
    EOF
    @recipients = 'activity@myousica.com'
    @from       = 'newtrack@myousica.com'
  end

  def new_song_notification(song)
    @subject    = "New song created: #{song.title}"
    @body       = <<-EOF
Title : #{song.title}
Author: #{song.original_author}
Descr.: #{song.description}
User  : #{song.user.login rescue nil}
Tone  : #{song.tone}
Length: #{song.length}
Genre : #{song.genre.name rescue nil}

#{APPLICATION[:url]}#{song_path(song)}
#{APPLICATION[:url]}#{song.public_filename}
    EOF
    @recipients = 'activity@myousica.com'
    @from       = 'newsong@myousica.com'
  end

  def new_answer_notification(answer)
    @subject    = "New question posted by #{answer.user.login}"
    @body       = <<-EOF
User: #{answer.user.login}
Body follows.
---------------8<------- cut ------- >8---------------
#{answer.body}
---------------8<------- cut ------- >8---------------

#{APPLICATION[:url]}#{answer_path(answer)}
    EOF
    @recipients = 'activity@myousica.com'
    @from       = 'newquestion@myousica.com'
  end

end
