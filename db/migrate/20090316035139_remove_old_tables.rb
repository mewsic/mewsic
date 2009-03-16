class RemoveOldTables < ActiveRecord::Migration
  def self.up
    drop_table :band_members
    drop_table :genres
  end

  def self.down
    create_table "band_members", :force => true do |t|
      t.string   "nickname",       :limit => 20
      t.integer  "instrument_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "country",        :limit => 45
      t.integer  "linked_user_id"
    end

    create_table "genres", :force => true do |t|
      t.string "name"
    end

  end
end
