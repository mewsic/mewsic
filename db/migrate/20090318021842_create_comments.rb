class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :title, :limit => 60
      t.text :body

      t.references :commentable, :polymorphic => true
      t.references :user

      t.integer :rating_count
      t.decimal :rating_total, :precision => 10, :scale => 2
      t.decimal :rating_avg, :precision => 10, :scale => 2

      t.timestamps
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
