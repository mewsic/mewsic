namespace :myousica do
  desc "Aggiorna il numero degli amici di una persona"
  task(:update_friends_count => :environment) do
    User.find(:all).each {|u| u.update_friends_count}
  end
end