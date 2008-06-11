class ShortenBandMemberNameLenght < ActiveRecord::Migration
  def self.up
    change_column :band_members, :name, :string, :limit => 20
  end

  def self.down
    change_column :band_members, :name, :string
  end
end
