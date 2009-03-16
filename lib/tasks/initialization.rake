namespace :mewsic do

  desc "Populate the development environment"
  task :initialize => ["db:migrate", "mewsic:directories", "mewsic:fixtures:load",
      #"mewsic:flash:update", "mewsic:videos:download",
      ]

  desc "Create all required mewsic directories"
  task :directories => :environment do
    Rake::Task['tmp:create'].invoke
    mkdir_p 'index'
    mkdir_p 'log'
  end

  desc "Update friends count for every user"
  task(:update_friends_count => :environment) do
    puts "* Updating friends count.."
    User.find(:all).each {|u| u.update_friends_count}
  end
  
  desc "Update answer replies count for every answer and every user"
  task(:update_replies_count => :environment) do
    puts "* Updating answer replies count.."
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

  desc "Copy the test mp3s from test/fixtures/files to public/audio"
  task(:copy_test_mp3s => :environment) do
    puts "* Copying test mp3s into public/audio"
    FileUtils.mkdir_p File.join(RAILS_ROOT, 'public', 'audio')

    %w(mp3 png).each do |ext|
      FileUtils.cp File.join(RAILS_ROOT, 'test', 'fixtures', 'files', "test.#{ext}"),
        File.join(RAILS_ROOT, 'public', 'audio')
    end
  end

  task(:update_nested_set => :environment) do
    puts "* Updating Song nested set"
    Song.find(:all).each { |s| s.send(:set_default_left_and_right); s.save! }
  end

  namespace :fixtures do
    desc "Load fixtures and update both friends and replies count"
    task :load => [ "db:fixtures:load",  "mewsic:update_friends_count",
      "mewsic:update_replies_count", "mewsic:copy_test_mp3s",
      "mewsic:update_nested_set"]
  end  
end
