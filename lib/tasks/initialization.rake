namespace :mewsic do

  desc "Populate the development environment"
  task :initialize => ["db:migrate", "mewsic:directories", "mewsic:fixtures:load",
      #"mewsic:flash:update", "mewsic:videos:download",
      "mewsic:sphinx:config", "mewsic:sphinx:initialize", "mewsic:sphinx:start"]

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

  namespace :fixtures do
    desc "Load fixtures and update both friends and replies count"
    task :load => [ "db:fixtures:load",  "mewsic:update_friends_count",
      "mewsic:update_replies_count", "mewsic:copy_test_mp3s"]
  end  

  namespace :sphinx do
    config = File.join(RAILS_ROOT, 'config', "sphinx_#{RAILS_ENV}.config")

    desc "Generate sphinx development config file"
    task(:config => :environment) do
      puts "* Generating Sphinx config file into #{config}"

      FileUtils.mkdir_p File.join(RAILS_ROOT, 'index')
      File.open(config, 'w+') do |f|
        f.write ERB.new(File.read(File.join(RAILS_ROOT, 'config', 'sphinx.config.erb'))).result
      end
    end

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

    desc "Initialize sphinx indices"
    task(:initialize => :environment) do
      puts `indexer --config #{config} --all`
    end

  end
end
