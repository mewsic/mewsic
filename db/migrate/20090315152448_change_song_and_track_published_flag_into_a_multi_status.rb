class ChangeSongAndTrackPublishedFlagIntoAMultiStatus < ActiveRecord::Migration
  def self.up
    rename_column :songs, :published, :status
    change_column :songs, :status, :integer, :default => Song.statuses.temporary

    Song.update_all ['status = ?', Song.statuses.public], 'status = 1'
    Song.update_all ['status = ?', Song.statuses.private], 'status = 0'

    rename_column :tracks, :published, :status
    change_column :tracks, :status, :integer, :default => Track.statuses.private

    Track.update_all ['status = ?', Track.statuses.public], 'status = 1'
    Track.update_all ['status = ?', Track.statuses.private], 'status = 0'
  end

  def self.down
    rename_column :songs, :status, :published
    change_column :songs, :published, :boolean, :default => false

    Song.update_all ['published = ?', true], ['published = ?', Song.statuses.public]
    Song.update_all ['published = ?', false], ['published IN (?)', Song.statuses.values_at(:private, :deleted, :temporary)]

    rename_column :tracks, :status, :published
    change_column :tracks, :published, :boolean, :default => false

    Track.update_all ['published = ?', true], ['published = ?', Track.statuses.public]
    Track.update_all ['published = ?', false], ['published IN (?)', Track.statuses.values_at(:private, :deleted)]
  end
end
