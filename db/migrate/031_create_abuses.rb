class CreateAbuses < ActiveRecord::Migration
  def self.up
    create_table :abuses do |t|
      t.integer :item_id
      t.string  :item_type
      t.integer :user_id
      t.text    :body

      t.timestamps
    end
  end

  def self.down
    drop_table :abuses
  end
end
