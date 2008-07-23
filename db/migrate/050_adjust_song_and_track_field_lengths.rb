class AdjustSongAndTrackFieldLengths < ActiveRecord::Migration
  def self.up
    change_column :songs, :title,           :string, :limit => 60
    change_column :songs, :original_author, :string, :limit => 60
    change_column :songs, :tone,            :string, :limit => 2
    change_column :songs, :filename,        :string, :limit => 64

    change_column :tracks, :title,          :string, :limit => 60
    change_column :tracks, :tonality,       :string, :limit => 2
    change_column :tracks, :filename,       :string, :limit => 64
  end

  def self.down
    change_column :songs, :title,           :string, :limit => 255
    change_column :songs, :original_author, :string, :limit => 255
    change_column :songs, :tone,            :string, :limit => 255
    change_column :songs, :filename,        :string, :limit => 255

    change_column :tracks, :title,          :string, :limit => 255
    change_column :tracks, :tonality,       :string, :limit => 255
    change_column :tracks, :filename,       :string, :limit => 255
  end
end
