class RemoveRepliesTable < ActiveRecord::Migration
  def self.up
    drop_table :replies
  end

  def self.down
    create_table "replies", :force => true do |t|
      t.integer  "answer_id"
      t.integer  "user_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "rating_count"
      t.decimal  "rating_total", :precision => 10, :scale => 2
      t.decimal  "rating_avg",   :precision => 10, :scale => 2
    end
  end
end
