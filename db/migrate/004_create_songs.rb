class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string  :title, :original_author
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
