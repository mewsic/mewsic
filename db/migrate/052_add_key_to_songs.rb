class AddKeyToSongs < ActiveRecord::Migration
  def self.up
    add_column :songs, :key, :integer
    Song.find(:all).each do |s|
      key = Myousica::TONES.index(s.tone.to_s.upcase)
      if key
        s.update_attribute(:key, key)
      end
    end
  end

  def self.down
    remove_column :songs, :key
  end
end
