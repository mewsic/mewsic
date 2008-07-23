namespace :myousica do
  desc "Aggiorna il numero degli amici di una persona"
  task(:update_friends_count => :environment) do
    User.find(:all).each {|u| u.update_friends_count}
  end
  
  desc "Aggiorna il numero di replies per ogni answer"
  task(:update_replies_count => :environment) do
    Answer.find(:all).each {|a| a.update_replies_count}
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
