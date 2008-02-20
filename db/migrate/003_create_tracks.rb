class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :title, :filename, :description
      t.integer :song_id, :instrument_id, :bpm
      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
