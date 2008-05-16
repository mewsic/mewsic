class CreateMbands < ActiveRecord::Migration
  def self.up
    create_table :mbands do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :mbands
  end
end
