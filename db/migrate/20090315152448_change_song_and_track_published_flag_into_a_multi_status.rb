class ChangeSongAndTrackPublishedFlagIntoAMultiStatus < ActiveRecord::Migration
  def self.up
    rename_column :songs, :published, :status
    change_column :songs, :status, :integer, :default => Song::Status[:temporary]
    Song.update_all ['status = ?', Song::Status[:public]], 'status = 1'
    Song.update_all ['status = ?', Song::Status[:private]], 'status = 0'

    rename_column :tracks, :published, :status
    change_column :tracks, :status, :integer, :default => Track::Status[:private]

    Track.update_all ['status = ?', Track::Status[:public]]
  end

  def self.down
    rename_column :songs, :status, :published
    change_column :songs, :status, :boolean, :default => false
    Song.update_all ['published = ?', true], ['published = ?', Song::Status[:public]]
    Song.update_all ['published = ?', false], ['published IN (?)', Song::Status.values_at(:private, :deleted, :temporary)]

    rename_column :tracks, :status, :published
    change_column :tracks, :status, :boolean, :default => false

    Track.update_all ['published = ?', true], ['published = ?', Track::Status[:public]]
    Track.update_all ['published = ?', false], ['published IN (?)', Track::Status.values_at(:private, :deleted)]
  end
end
