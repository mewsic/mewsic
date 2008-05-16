class CreateMbands < ActiveRecord::Migration
  def self.up
    create_table :mbands do |t|
      t.string :name
      t.string :photos_url
      t.string :blog_url
      t.string :myspace_url
      t.text :motto
      t.text :tastes
      t.integer :friends_count, :default  => nil
      t.integer :user_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mbands
  end
end
