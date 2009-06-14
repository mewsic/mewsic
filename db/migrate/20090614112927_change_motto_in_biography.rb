class ChangeMottoInBiography < ActiveRecord::Migration
  def self.up
    rename_column :users, :motto, :biography
  end

  def self.down
    rename_column :users, :biography, :motto
  end
end
