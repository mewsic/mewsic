class AddPodcastFlagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :podcast_public, :boolean, :default => true
  end

  def self.down
    remove_column :users, :podcast_public
  end
end
