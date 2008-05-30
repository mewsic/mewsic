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
  
end