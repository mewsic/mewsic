class CreateBandMembers < ActiveRecord::Migration
  def self.up
    create_table :band_members do |t|
      t.string  :name
      t.integer :instrument_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :band_members
  end
end
