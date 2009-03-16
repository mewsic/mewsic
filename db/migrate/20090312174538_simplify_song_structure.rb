class SimplifySongStructure < ActiveRecord::Migration
  def self.up
    rename_column :songs, :original_author, :author
    change_column :songs, :description, :text

    remove_column :songs, :tone
    remove_column :songs, :genre_id
    remove_column :songs, :bpm
    remove_column :songs, :key

    add_column :tracks, :author, :string, :limit => 60
    change_column :tracks, :description, :text

    remove_column :tracks, :tonality
    remove_column :tracks, :bpm
    remove_column :tracks, :idea
    remove_column :tracks, :instrument_description
    remove_column :tracks, :key
  end

  def self.down
    #rename_column :songs, :author, :original_author
    change_column :songs, :description, :string

    add_column :songs, :tone, :string, :limit => 2
    add_column :songs, :genre_id, :integer
    add_column :songs, :bpm, :integer
    add_column :songs, :key, :integer

    remove_column :tracks, :author
    change_column :tracks, :description, :string

    add_column :tracks, :tonality, :string, :limit => 2, :default => 'C'
    add_column :tracks, :bpm, :integer
    add_column :tracks, :idea, :boolean, :default => false, :null => false
    add_column :tracks, :instrument_description, :string
    add_column :tracks, :key, :integer
  end
end
