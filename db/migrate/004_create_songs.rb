class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string  :title, :original_author, :description, :tone, :filename
      t.integer :user_id, :genre_id, :bpm
      t.integer :listened_times, :default => 0
      t.boolean :published, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
