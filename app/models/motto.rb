class Motto
  @@phrases = File.read(File.join(RAILS_ROOT, 'app', 'views', 'dashboard', 'motto.txt')).split("\n")
  def self.find(*args)
    @@phrases.sort_by{rand}.first
  end
end

