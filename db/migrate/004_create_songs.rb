class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string  :title, :original_author
      t.integer :user_id, :genre_id, :listened_times
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
