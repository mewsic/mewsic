class AddRepliesCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :replies_count, :integer
  end

  def self.down
    remove_column :users, :replies_count
  end
end
