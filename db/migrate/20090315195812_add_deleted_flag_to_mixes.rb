class AddDeletedFlagToMixes < ActiveRecord::Migration
  def self.up
    add_column :mixes, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :mixes, :deleted
  end
end
