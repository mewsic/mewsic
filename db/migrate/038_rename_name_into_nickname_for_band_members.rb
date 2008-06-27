class RenameNameIntoNicknameForBandMembers < ActiveRecord::Migration
  def self.up
    rename_column :band_members, :name, :nickname
  end

  def self.down
    rename_column :band_members, :nickname, :name
  end
end
