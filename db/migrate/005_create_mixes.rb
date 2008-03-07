class CreateMixes < ActiveRecord::Migration
  def self.up
    create_table :mixes do |t|
      t.integer :song_id, :track_id, :volume, :loop, :balance, :time_shift
      t.timestamps
    end
  end

  def self.down
    drop_table :mixes
  end
end
