class CreateMixes < ActiveRecord::Migration
  def self.up
    create_table :mixes do |t|
      t.integer   :song_id
      t.integer   :track_id
      t.integer   :volume
      t.integer   :loop
      t.float     :balance, :default => 0
      t.integer   :time_shift
      t.timestamps
    end
  end

  def self.down
    drop_table :mixes
  end
end
