class SimplifySongStructure < ActiveRecord::Migration
  def self.up
    rename_column :songs, :original_author, :author
    change_column :songs, :description, :text

    remove_column :songs, :tone
    remove_column :songs, :genre_id
    remove_column :songs, :bpm
    remove_column :songs, :key

    add_column :tracks, :author, :limit => 60
    change_column :tracks, :description, :text

    remove_column :tracks, :tonality
    remove_column :tracks, :bpm
    remove_column :tracks, :idea
    remove_column :tracks, :instrument_description
    remove_column :tracks, :key
  end

  def self.down
    rename_column :songs, :author, :original_author

    add_column :songs, :string, "original_author", :limit => 60
    add_column :songs, :string, "description"
    add_column :songs, :string, "tone", :limit => 2
    add_column :songs, :integer, "genre_id"
    add_column :songs, :integer, "bpm"
    add_column :songs, :integer, "key"

    add_column :tracks, :string, "description"
    add_column :tracks, :string, "tonality", :limit => 2, :default => "C"
    add_column :tracks, :integer, "bpm"
    add_column :tracks, :boolean, "idea", :default => false, :null => false
    add_column :tracks, :string, "instrument_description"
    add_column :tracks, :integer, "key"
  end
end
