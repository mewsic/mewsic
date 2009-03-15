class AddFeaturings < ActiveRecord::Migration
  def self.up
    create_table :featurings do |t|
      t.integer :song_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :featurings
  end
end
