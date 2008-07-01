class AddUserLastActivity < ActiveRecord::Migration
  def self.up
    add_column :users, :last_activity_at, :datetime, :null => true, :default => nil
  end

  def self.down
    remove_column :users, :last_activity_at
  end
end
