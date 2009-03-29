class NewlyCreatedTracksAreAlwaysTemporary < ActiveRecord::Migration
  def self.up
    change_column :tracks, :status, :integer, :default => Track.statuses.temporary
    change_column :tracks, :title, :string, :default => 'Untitled'
  end

  def self.down
    change_column :tracks, :status, :integer, :default => Track.statuses.private
    change_column :tracks, :title, :string, :default => ''
  end
end
