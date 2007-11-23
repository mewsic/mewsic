class CreateMixes < ActiveRecord::Migration
  def self.up
    create_table :mixes do |t|
      t.integer :song_id, :track_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mixes
  end
end
