STAGE_SERVER = 'mewsic.stage.lime5.it'
RDOC_DIR='/srv'

namespace :mewsic do

  desc "Populate the development environment"
  task :initialize => ["db:migrate", "mewsic:directories", "mewsic:fixtures:load",
      "mewsic:flash:update", "mewsic:videos:download", "mewsic:sphinx:config",
      "mewsic:sphinx:initialize", "mewsic:sphinx:start"]

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

  namespace :flash do
    desc "Update the flash swfs"
    task(:update => :environment) do
      def update(path)
        FileUtils.mkdir_p File.join(RAILS_ROOT, 'public', *path[0..-2])
        File.open File.join(RAILS_ROOT, 'public', *path), 'w+' do |f|
          uri = URI.parse "http://#{STAGE_SERVER}/#{path.join('/')}"
          puts "  Updating #{path.last} from #{uri}"
          f.write Net::HTTP.get(uri)
        end
      end

      puts "* Updating flash applications"

      update ['multitrack', 'Multitrack_Editor.swf']
      update ['players', 'Player.swf']
      update ['players', 'Video_Player.swf']
      update ['splash', 'Splash.swf']
      (1..3).each { |i| update ['splash', 'slides', "#{i}.jpg"] }
    end
  end

  namespace :videos do
    desc "Download current videos from #{STAGE_SERVER}"
    task(:download => :environment) do
      path = File.join(RAILS_ROOT, 'public', 'videos')

      FileUtils.mkdir_p path
      Video.find(:all).each do |video|
        puts "* Processing #{video.description} video"

        [:filename, :highres, :poster, :thumb].each do |kind|
          uri = URI.parse("http://#{STAGE_SERVER}#{video.public_filename(kind)}")
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

  def rsync(local, remote)
    sh("rsync -rlt4 --exclude README.html --exclude HEADER.html --exclude .htaccess #{local} mewsic@#{STAGE_SERVER}:#{RDOC_DIR}/#{remote}")
  end

  namespace :doc do
    allison = %[allison --all --line-numbers --inline-source --charset utf-8]

    desc "Generate mewsic documentation"
    task :app => :environment do
      rm_rf 'doc/app' rescue nil
      files = FileList.new('app/**/*.rb', 'lib/**/*.rb')
      sh "#{allison} --title 'mewsic documentation' -o doc/app doc/README_FOR_APP #{files}"
    end

    desc "Generate plugins documentation"
    task :plugins => :environment do
      rm_rf 'doc/plugins' rescue nil
      FileList['vendor/plugins/**'].each do |plugin|
        name = File.basename(plugin)
        files = FileList.new("#{plugin}/lib/**/*.rb")
        option = nil

        if File.exist?("#{plugin}/README")
          files.include("#{plugin}/README")    
          option = "--main '#{plugin}/README'"
        end
        files.include("#{plugin}/CHANGELOG") if File.exist?("#{plugin}/CHANGELOG")
        
        sh "#{allison} --title 'mewsic - #{name} documentation' -o doc/plugins/#{name} #{option} #{files}"
      end
    end

    desc "Sync documentation on ulisse"
    task :sync => :environment do
      puts "R-syncing app doc to #{STAGE_SERVER}"
      rsync "#{RAILS_ROOT}/doc/app/*", "rdoc/mewsic"

      puts "R-syncing plugins doc to #{STAGE_SERVER}"
      rsync "#{RAILS_ROOT}/doc/plugins/*", "rdoc/mewsic/plugins"
    end
  end

  namespace :rcov do
    desc "Sync coverage on ulisse"
    task :sync => :environment do
      puts "Running coverage tests"
      Rake::Task['test:units:rcov'].invoke
      Rake::Task['test:functionals:rcov'].invoke
      Rake::Task['test:integration:rcov'].invoke

      puts "R-syncing coverage to #{STAGE_SERVER}"
      rsync "#{RAILS_ROOT}/coverage/*", "rcov/mewsic"
    end
  end
  
end
