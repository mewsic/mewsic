class AddPublicNameFlagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :name_public, :boolean, :default => false
  end

  def self.down
    remove_column :users, :name_public
  end
end
