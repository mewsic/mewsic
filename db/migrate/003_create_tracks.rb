class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string  :title
      t.string  :filename
      t.string  :description
      t.string  :tonality, :default => 'C'
      t.integer :song_id
      t.integer :instrument_id
      t.integer :seconds, :default => 0
      t.integer :bpm
      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
