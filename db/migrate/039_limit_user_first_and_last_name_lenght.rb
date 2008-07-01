class LimitUserFirstAndLastNameLenght < ActiveRecord::Migration
  def self.up
    change_column :users, :first_name, :string, :limit => 32
    change_column :users, :last_name, :string, :limit => 32
  end

  def self.down
    change_column :users, :first_name, :string
    change_column :users, :last_name, :string
  end
end
