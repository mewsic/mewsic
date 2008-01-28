class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      
      t.string :login, :email, :remember_token, :country, :city
      t.string :crypted_password, :salt, :limit => 40
      t.text :motto, :tastes
      t.datetime :remember_token_expires_at
      t.integer :friends_count, :default  => nil
      
      t.timestamps      
      
    end
    
    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
