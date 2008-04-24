class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.integer :pictureable_id
      t.string  :pictureable_type
      t.string  :type
      t.integer :size
      t.string  :content_type, :filename, :string, :thumbnail
      t.integer :height, :width, :parent_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
