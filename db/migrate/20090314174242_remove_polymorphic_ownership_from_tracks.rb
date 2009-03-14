class RemovePolymorphicOwnershipFromTracks < ActiveRecord::Migration
  def self.up
    remove_column :tracks, :user_type
  end

  def self.down
    add_column :tracks, :user_type, :string, :limit => 10
  end
end
