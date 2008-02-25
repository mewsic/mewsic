namespace :myousica do
  desc "Aggiorna il numero degli amici di una persona"
  task(:update_friends_count => :environment) do
    User.find(:all).each {|u| u.update_friends_count}
  end
  
  namespace :fixtures do
    desc "Carica le fixtures ed aggiorna il numero degli amici di una persona"
    task :load => [ "db:fixtures:load",  "myousica:update_friends_count"]
  end
  
end