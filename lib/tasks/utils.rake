namespace :mewsic do
  
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

  namespace :doc do
    rdoc = %[rdoc --all --line-numbers --inline-source --charset utf-8]

    desc "Generate mewsic documentation"
    task :app => :environment do
      rdoc_dir = ENV['RDOC_OUTPUT'] || 'doc/app'
      rm_rf rdoc_dir rescue nil
      files = FileList.new('app/**/*.rb', 'lib/**/*.rb')
      sh "#{rdoc} --title 'mewsic documentation' -o #{rdoc_dir} doc/README_FOR_APP #{files}"
    end

    #desc "Generate plugins documentation"
    #task :plugins => :environment do
    #  rdoc_dir = (ENV['RDOC_OUTPUT'] || 'doc/app') + '/plugins'
    #  rm_rf rdoc_dir rescue nil
    #  FileList['vendor/plugins/**'].each do |plugin|
    #    name = File.basename(plugin)
    #    files = FileList.new("#{plugin}/lib/**/*.rb")
    #    option = nil
    #    if File.exist?("#{plugin}/README")
    #      files.include("#{plugin}/README")    
    #      option = "--main '#{plugin}/README'"
    #    end
    #    files.include("#{plugin}/CHANGELOG") if File.exist?("#{plugin}/CHANGELOG")
    #    
    #    sh "#{rdoc} --title 'mewsic - #{name} documentation' -o #{rdoc_dir}/#{name} #{option} #{files}"
    #  end
    #end

  end
    
  # Cruisecontrol task
  task :cruise => :environment do
    puts 'Migrating database..'
    Rake::Task['db:migrate'].invoke

    puts 'Generating documentation..'
    ENV['RDOC_OUTPUT'] = '/srv/rdoc/mewsic'
    Rake::Task['mewsic:doc:app'].invoke
    #Rake::Task['mewsic:doc:plugins'].invoke

    puts 'Running coverage tests..'
    ENV['RCOV_OUTPUT'] = '/srv/rcov/mewsic'
    Rake::Task['test:coverage'].invoke
  end
  
end
