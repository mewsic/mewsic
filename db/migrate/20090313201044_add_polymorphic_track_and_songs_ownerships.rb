class AddPolymorphicTrackAndSongsOwnerships < ActiveRecord::Migration
  def self.up
    add_column :songs, :user_type, :string, :limit => 10
    add_column :tracks, :user_type, :string, :limit => 10

    [Song, Track].each { |model| 
      model.update_all "user_type = 'User'", 'id % 2 = 0'
      model.update_all "user_type = 'Mband'", 'id % 2 = 1'
    }
  end

  def self.down
    remove_column :songs, :user_type, :limit => 10
    remove_column :tracks, :user_type, :limit => 10
  end
end
