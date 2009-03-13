class AddTrackPublishedStatus < ActiveRecord::Migration
  def self.up
    add_column :tracks, :published, :boolean, :default => false
  end

  def self.down
    remove_column :tracks, :published, :boolean
  end
end
