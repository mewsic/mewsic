class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.belongs_to :user
      t.integer :size
      t.string :content_type, :filename, :string
      t.integer :height, :width, :parent_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
