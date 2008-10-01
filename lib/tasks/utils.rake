namespace :myousica do
  desc "Aggiorna il numero degli amici di una persona"
  task(:update_friends_count => :environment) do
    User.find(:all).each {|u| u.update_friends_count}
  end
  
  desc "Aggiorna il numero di replies per ogni answer ed ogni user"
  task(:update_replies_count => :environment) do
    Answer.find(:all).each do |answer|
      answer.connection.execute(
        "UPDATE answers SET replies_count = #{answer.replies.count} WHERE id = #{answer.id}"
      )
    end

    User.find(:all).each do |user|
      user.connection.execute(
        "UPDATE users SET replies_count = #{user.replies.count} WHERE id = #{user.id}"
      )
    end
  end    

  namespace :sphinx do
    config = File.join(RAILS_ROOT, 'config', 'sphinx_development.config')

    desc "Start sphinx with development config"
    task(:start => :environment) do
      puts `searchd --config #{config}`
    end

    task(:stop => :environment) do
      puts `searchd --config #{config} --stop`
    end

    task(:rehash => :environment) do
      puts `indexer --config #{config} --all --rotate`
    end

  end
  
  namespace :fixtures do
    
    desc "Carica le fixtures ed aggiorna il numero degli amici di una persona"
    task :load => [ "db:fixtures:load",  "myousica:update_friends_count", "myousica:update_replies_count"]
    
    desc "Setto un mp3 come default x tutte le song e track"
    task :dragonforce => :environment do
      Track.update_all("filename = 'audio/dragonforce.mp3'")
      Song.update_all("filename = 'audio/dragonforce.mp3'")
    end
    
  end  

  desc "Clean up unreferenced mp3s"
  task :clean_up_mp3s => :environment do
    unless ENV['MP3DIR']
      raise ArgumentError, "Please define MP3DIR in the environment"
    end

    mp3s = (Track.find(:all, :select => 'filename', :conditions => 'filename IS NOT NULL').map(&:filename) +
            Song.find(:all, :select => 'filename', :conditions => 'filename IS NOT NULL').map(&:filename))
    mp3s.map! { |f| File.basename(f) }

    Dir[File.join(ENV['MP3DIR'], '*.mp3')].each do |f|
      if !mp3s.include?(File.basename(f))
        #puts "removing #{f}"
        File.unlink f
        File.unlink f.sub(/mp3$/, 'png')
      end
    end
  end
  
end
