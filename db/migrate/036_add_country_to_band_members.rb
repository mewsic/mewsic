class AddCountryToBandMembers < ActiveRecord::Migration
  def self.up
    add_column :band_members, :country, :string, :limit => 45
  end

  def self.down
    remove_column :band_members, :country
  end
end
