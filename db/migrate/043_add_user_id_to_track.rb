class AddUserIdToTrack < ActiveRecord::Migration
  def self.up
    add_column :tracks, :user_id, :integer
  end

  def self.down
    remove_column :tracks, :user_id
  end
end
