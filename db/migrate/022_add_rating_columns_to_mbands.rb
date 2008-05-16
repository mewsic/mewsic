class AddRatingColumnsToMbands < ActiveRecord::Migration
  def self.up
    Mband.add_ratings_columns
  end

  def self.down
    Mband.remove_ratings_columns
  end
end
