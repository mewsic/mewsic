class AddKeyToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :key, :integer
    Track.find(:all).each do |t|
      key = Myousica::TONES.index(t.tonality.upcase)            
      if key
        t.update_attribute(:key, key)
      end
    end     
  end

  def self.down
    remove_column :tracks, :key
  end
end
