class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :name,        :limit => 32
      t.string :description, :limit => 255
      t.string :filename,    :limit => 64
      t.string :poster,      :limit => 64
      t.string :highres,     :limit => 64
      t.string :thumb,       :limit => 64

      t.integer :length
      t.integer :position 

      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
