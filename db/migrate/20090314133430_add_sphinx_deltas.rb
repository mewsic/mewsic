class AddSphinxDeltas < ActiveRecord::Migration
  def self.up
    add_column :answers, :delta, :boolean, :default => false
    add_column :mbands, :delta, :boolean, :default => false
    add_column :songs, :delta, :boolean, :default => false
    add_column :tracks, :delta, :boolean, :default => false
    add_column :users, :delta, :boolean, :default => false
  end

  def self.down
    remove_column :answers, :delta
    remove_column :mbands, :delta
    remove_column :songs, :delta
    remove_column :tracks, :delta
    remove_column :users, :delta
  end
end
