class AddRatingTables < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_ratings_table
    
    User.add_ratings_columns
    Track.add_ratings_columns
    Song.add_ratings_columns
  end
  
  def self.down
    User.remove_ratings_columns
    Track.remove_ratings_columns
    Song.remove_ratings_columns
    
    ActiveRecord::Base.drop_ratings_table
  end
end
