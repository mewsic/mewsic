# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This mailer sends out user help requests (HelpRequest model), collaboration
# notifications and administrative ones when a new User, Song, Track or Answer
# is created.
#
# Collaboration notifications are triggered when an user creates a new Song
# using a Track from another user.
#
# Each method is self-documenting, help requests are sent from help@myousica.com
# while administrivia comes from activity@myousica.com.
#
class MyousicaMailer < ActionMailer::Base

  def help_request(request, sent_at = Time.now)
    @subject    = 'Myousica Help Question'
    @body       = request.body
    @recipients = 'help@myousica.com'
    @from       = request.email
    @sent_on    = sent_at
    @headers    = {}
  end

  def collaboration_notification(recipient, song, tracks)
    @subject    = %[ Bravo! Myousician "#{song.user.login}" has used your tracks in a new myousica song! ]
    @recipients = recipient.email
    @from       = 'noreply@myousica.com'
    @layout     = 'user_mailer'

    @body[:user] = recipient
    @body[:song] = song
    @body[:tracks] = tracks
  end

  def new_user_notification(user)
    @subject    = "New user registration: #{user.login}"
    @recipients = 'activity@myousica.com'
    @from       = 'register@myousica.com'

    @body[:user] = user
  end

  def new_track_notification(track)
    @subject    = "New track created: #{track.title}"
    @recipients = 'activity@myousica.com'
    @from       = 'newtrack@myousica.com'

    @body[:track] = track
  end

  def new_song_notification(song)
    @subject    = "New song created: #{song.title}"
    @recipients = 'activity@myousica.com'
    @from       = 'newsong@myousica.com'

    @body[:song] = song
  end

  def new_answer_notification(answer)
    @subject    = "New question posted by #{answer.user.login}"
    @recipients = 'activity@myousica.com'
    @from       = 'newquestion@myousica.com'

    @body[:answer] = answer
  end

end
