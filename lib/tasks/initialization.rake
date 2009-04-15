namespace :mewsic do

  desc "Populate the development environment"
  task :initialize => ["db:migrate", "mewsic:directories", "mewsic:generate_instruments_fixture",
    "mewsic:fixtures:load", "mewsic:generate_instruments_assets",
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
  
  desc "Update comment counters for every answer and every user"
  task(:update_comments_count => :environment) do
    print '* Updating comments count:'
    [Answer, Mband, Song, Track, User].each do |model|
      Comment.count(:all, :conditions => "commentable_type = '#{model}'", :group => :commentable_id).each do |id, count|
        model.connection.execute "UPDATE #{model.table_name} SET comments_count = #{count} WHERE id = #{id}"
      end
      print ' ' + model.name
    end

    Comment.count(:all, :group => :user_id).each do |id, count|
      User.connection.execute "UPDATE #{User.table_name} SET comments_count = #{count} WHERE id = #{id}"
    end
    puts '.'
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
    desc "Load fixtures and update both friends and comments count"
    task :load => [ "db:fixtures:load",  "mewsic:update_friends_count",
      "mewsic:update_comments_count", "mewsic:copy_test_mp3s",
      "mewsic:update_nested_set"]
  end  

  # Generate test/fixtures/instruments.yml using the table located in
  # test/fixtures/instruments.txt. fields are separated by spaces, first
  # column is instrument code, the second is the instrument category
  # code (optional).
  # 
  task(:generate_instruments_fixture => :environment) do
    position = -1
    fixtures = 
      File.readlines(File.join(*%W(test fixtures instruments.txt))).map do |line|
        code, category = line.split(/\s+/)
        %|
#{code}:
  description: #{code.humanize}
  icon: #{code}.png#{"\n  category: " + category if category}
  position: #{position += 1}
|
    end.unshift("# GENERATED FROM test/fixtures/instruments.txt\n# @#{Time.now}\n#")

    File.open(File.join(*%W(test fixtures instruments.yml)), 'w+') do |f|
      f.write(fixtures.join)
    end

    puts "* Generated test/fixtures/instruments.yml (#{position + 1} instruments)"
  end

  # Generate the individual instrument icons by cropping the big png tables, because
  # the icons are used by the multitrack. Configurable variables: SIZES contains the
  # name of the png table, used to construct the file path, and the icon size in px.
  # PER_ROW is the number of elements per row. 
  #
  # { :white => 40 } looks for public/images/icons/instruments_white.png and generates
  # 40px images into public/images/instruments/white for each instrument stored in the
  # database.
  #
  # It also generates public/stylesheets/instruments/white.css, where selectors are
  # like this: .instr.<name>.<Instrument#code>
  #
  task(:generate_instruments_assets => :environment) do
    require 'image_science'

    SIZES = {:white => 40, :big => 60}
    PER_ROW = 7

    SIZES.each do |name, size|

      # Generate thumbnails
      #
      basedir = File.join *%W(public images instruments #{name})
      FileUtils.mkdir_p basedir
      puts "* Instruments assets: mkdir `#{basedir}'"

      css = {}

      ImageScience.with_image File.join(*%W(public images icons instruments_#{name}.png)) do |background|

        Instrument.find(:all, :order => :position).each do |instrument|
          left   = instrument.position % PER_ROW * size
          top    = instrument.position / PER_ROW * size
          right  = left + size
          bottom = top  + size

          css[instrument] = [-left, -top]

          background.with_crop(left, top, right, bottom) do |thumb|
            thumb.save File.join(basedir, instrument.icon)
          end
        end

        puts "* Instruments assets: wrote #{Instrument.count} `#{name}' icons, #{size}x#{size}px"
      end

      # Generate CSS
      #
      basename = basedir.sub 'images', 'stylesheets'
      FileUtils.mkdir_p File.join(*%w(public stylesheets instruments))

      css = css.map do |instrument, coords|
        left, top = coords.map { |i| i == 0 ? i : "#{i}px" }
        ".instr.#{name}.#{instrument.code} { background-position: #{left} #{top}; }"
      end.unshift("/* GENERATED BY rake mewsic:generate_instruments_assets ON #{Time.now} */")

      File.open("#{basename}.css", 'w+') do |file|
        file.write css.join("\n")
      end

      puts "* Instruments assets: wrote #{basename}.css"

    end

  end
end
