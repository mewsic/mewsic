class AddUserStatusTristate < ActiveRecord::Migration
  def self.up
    remove_column :users, :last_activity_at
    add_column :users, :status, :string, :limit => 3, :default => 'off'
  end

  def self.down
    remove_column :users, :status
    add_column :users, :last_activity_at, :datetime
  end
end
