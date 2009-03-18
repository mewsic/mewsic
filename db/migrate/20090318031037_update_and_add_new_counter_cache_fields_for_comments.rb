class UpdateAndAddNewCounterCacheFieldsForComments < ActiveRecord::Migration
  def self.up
    add_column :mbands, :comments_count, :integer, :default => 0
    add_column :songs, :comments_count, :integer, :default => 0
    add_column :tracks, :comments_count, :integer, :default => 0
    add_column :users, :comments_count, :integer, :default => 0

    rename_column :answers, :replies_count, :comments_count
    rename_column :users, :replies_count, :writings_count
  end

  def self.down
    rename_column :users, :writings_count, :replies_count
    rename_column :answers, :comments_count, :replies_count

    remove_column :users, :comments_count
    remove_column :tracks, :comments_count
    remove_column :songs, :comments_count
    remove_column :mbands, :comments_count
  end
end
