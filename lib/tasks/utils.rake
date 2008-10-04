namespace :myousica do

  desc "Populate the development environment"
  task :initialize => ["myousica:fixtures:load", "myousica:flash:update", "myousica:videos:download"]

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
    task :load => [ "db:fixtures:load",  "myousica:update_friends_count",
      "myousica:update_replies_count", "myousica:copy_test_mp3s"]
  end  

  namespace :flash do
    desc "Update the flash swfs from the production slices on EY"
    task(:update => :environment) do
      def update(path)
        FileUtils.mkdir_p File.join(RAILS_ROOT, 'public', *path[0..-2])
        File.open File.join(RAILS_ROOT, 'public', *path), 'w+' do |f|
          uri = URI.parse "http://myousica.com/#{path.join('/')}"
          puts "  Updating #{path.last} from #{uri}"
          f.write Net::HTTP.get(uri)
        end
      end

      puts "* Updating flash applications"

      update ['multitrack', 'Adelao_Myousica_Multitrack_Editor.swf']
      update ['players', 'Adelao_Myousica_Player.swf']
      update ['players', 'Adelao_Myousica_Video_Player.swf']
      update ['splash', 'Adelao_Myousica_Splash.swf']
      (1..3).each { |i| update ['splash', 'slides', "#{i}.jpg"] }
    end
  end

  namespace :videos do
    desc "Download current videos from myousica.com"
    task(:download => :environment) do
      path = File.join(RAILS_ROOT, 'public', 'videos')

      FileUtils.mkdir_p path
      Video.find(:all).each do |video|
        puts "* Processing #{video.description} video"

        [:filename, :highres, :poster, :thumb].each do |kind|
          uri = URI.parse("http://myousica.com#{video.public_filename(kind)}")
          printf "  Downloading #{video.description} #{kind} from #{uri} .. "
          $stdout.flush

          filename = File.join(path, video.send(kind))
          if File.exists? filename
            puts '[exists]'
            next
          end

          File.open(filename, 'w+') { |f| f.write Net::HTTP.get(uri) }
          puts 'done!'
        end
      end
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
