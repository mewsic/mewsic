class ShortenUserCityAndCountry < ActiveRecord::Migration
  def self.up
    change_column 'users', 'city', :string, :limit => 40
    change_column 'users', 'country', :string, :limit => 45
  end

  def self.down
    change_column 'users', 'city', :string, :limit => 255
    change_column 'users', 'country', :string, :limit => 255
  end
end
