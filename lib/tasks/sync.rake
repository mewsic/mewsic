STAGE_SERVER = 'mewsic.stage.lime5.it'

namespace :mewsic do

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

end
