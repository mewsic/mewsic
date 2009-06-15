class AddNewInfluencesToUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :tastes
    add_column :users, :influences_genres, :text
    add_column :users, :influences_artists, :text
    add_column :users, :influences_movies, :text
    add_column :users, :influences_books, :text
  end

  def self.down
    remove_column :users, :influences_genres
    remove_column :users, :influences_artists
    remove_column :users, :influences_movies
    remove_column :users, :influences_books
    add_column :users, :tastes, :text
  end
end
