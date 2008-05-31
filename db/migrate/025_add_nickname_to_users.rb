class AddNicknameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :nickname, :string, :limit => 20
    User.update_all 'nickname = login'
  end

  def self.down
    remove_column :users, :nickname
  end
end
