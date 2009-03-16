class MakeSongsANestedSet < ActiveRecord::Migration
  def self.up
    add_column :songs, :parent_id, :integer
    add_column :songs, :lft, :integer
    add_column :songs, :rgt, :integer
  end

  def self.down
    remove_column :songs, :parent_id
    remove_column :songs, :lft
    remove_column :songs, :rgt
  end
end
