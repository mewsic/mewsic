class RemoveDefaultFromUserGenderColumn < ActiveRecord::Migration
  def self.up
    change_column :users, :gender, :string, :limit => 20, :default => nil
  end

  def self.down
    change_column :users, :gender, :string, :default => 'male'
  end
end
