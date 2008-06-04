class ChangeUsersRepliesCountDefaultToZero < ActiveRecord::Migration
  def self.up
    change_column_default :users, :replies_count, 0
  end

  def self.down
    change_column_default :users, :replies_count, nil
  end
end
