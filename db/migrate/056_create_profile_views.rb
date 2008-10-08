class CreateProfileViews < ActiveRecord::Migration
  def self.up
    create_table :profile_views do |t|
      t.integer :user_id
      t.string :viewer, :limit => 32

      t.timestamps
    end

    add_column :users, :profile_views, :integer, :default => 0
  end

  def self.down
    drop_table :profile_views

    remove_column :users, :profile_views
  end
end
