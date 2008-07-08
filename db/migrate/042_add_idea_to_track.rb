class AddIdeaToTrack < ActiveRecord::Migration
  def self.up
    add_column :tracks, :idea, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :tracks, :idea
  end
end
