class AddMultitrackTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :multitrack_token, :string, :limit => 64
  end

  def self.down
    remove_column :users, :multitrack_token
  end
end
