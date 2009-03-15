class RemoveChildrenTracksParentSongAssociation < ActiveRecord::Migration
  def self.up
    remove_column :tracks, :song_id
  end

  def self.down
    add_column :tracks, :song_id, :integer
  end
end
