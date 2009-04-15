# XXX FIXME this file should contain constants for every object class
# present into fixtures, and be included in every of them.
# e.g. SONG_COUNT=200 MBAND_SONG_COUNT=50 USER_COUNT=500 and so on.
#
def random_rating
  rand * 5
end

def random_rating_count
  (1 / Math.log(rand(2**12)) * 2**8).to_i rescue 0
end

def random_title
  shuffle(lorem_ipsum[0..64]).capitalize + '.'
end

def random_description
  shuffle(lorem_ipsum).capitalize
end

def random_genre
  genres.sort_by{rand}.first
end

def random_user
  "user_#{rand(500)}"
end

def random_avatar
  @avatars ||= Dir['test/fixtures/files/avatars/*']
  @avatars.rand
end

def random_instrument
  @instruments ||= File.readlines('test/fixtures/instruments.txt').map { |l| l.split(/\s+/).first }
  @instruments.rand
end

def picture(name)
  "test/fixtures/files/#{name}"
end

# Randomly sorts the given array, truncating it to a
# random length, and joining its elements with spaces.
#
def shuffle(array)
  array.sort_by{rand}[0..rand(array.size)].join(' ')
end

# Returns lorem_ipsum as an array
#
def lorem_ipsum
  @lipsum ||= File.read(txt('lorem_ipsum')).split(' ')
end

# Returns an array with genres residing in genres.txt
#
def genres
  @genres ||= File.readlines(txt('genres')).map(&:strip)
end

# Read a txt file from test/fixtures/name.txt
#
def txt(name)
  File.join(RAILS_ROOT, 'test', 'fixtures', name + '.txt')
end
