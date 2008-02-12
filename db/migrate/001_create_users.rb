class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string :login, :email, :remember_token, :activation_code, :country, :city, :first_name, :last_name, :gender
      t.string :photos_url, :blog_url, :myspace_url, :skype, :msn
      t.boolean :msn_public, :default => false
      t.boolean :skype_public, :default => false
      t.string :crypted_password, :salt, :limit => 40
      t.string :type
      t.text :motto, :tastes
      t.datetime :remember_token_expires_at, :activated_at
      t.integer :friends_count, :default  => nil
      t.integer :age      
      
      t.timestamps      
      
    end
    
    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
