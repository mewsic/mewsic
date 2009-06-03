class AddRatingColumnsToAnswersAndReplies < ActiveRecord::Migration
  def self.up
    Answer.add_ratings_columns
    #Reply.add_ratings_columns
  end

  def self.down
    Answer.remove_ratings_columns
    #Reply.remove_ratings_columns
  end
end
