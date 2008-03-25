# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "answers", :force => true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "friend_id",   :null => false
    t.datetime "created_at"
    t.datetime "accepted_at"
  end

  create_table "genres", :force => true do |t|
    t.string "name"
  end

  add_index "genres", ["name"], :name => "index_genres_on_name"

  create_table "instruments", :force => true do |t|
    t.string   "description"
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "sender_deleted",    :default => false
    t.boolean  "recipient_deleted", :default => false
    t.string   "subject"
    t.text     "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mixes", :force => true do |t|
    t.integer  "song_id"
    t.integer  "track_id"
    t.integer  "volume"
    t.integer  "loop"
    t.integer  "balance"
    t.integer  "time_shift"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mlabs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "mixable_id"
    t.string   "mixable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.string   "string"
    t.string   "thumbnail"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer "rater_id"
    t.integer "rated_id"
    t.string  "rated_type"
    t.decimal "rating",     :precision => 10, :scale => 2
  end

  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"
  add_index "ratings", ["rated_type", "rated_id"], :name => "index_ratings_on_rated_type_and_rated_id"

  create_table "replies", :force => true do |t|
    t.integer  "answer_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "songs", :force => true do |t|
    t.string   "title"
    t.string   "original_author"
    t.string   "description"
    t.string   "tone"
    t.string   "filename"
    t.integer  "user_id"
    t.integer  "genre_id"
    t.integer  "listened_times"
    t.integer  "bpm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",    :precision => 10, :scale => 2
    t.decimal  "rating_avg",      :precision => 10, :scale => 2
  end

  create_table "tracks", :force => true do |t|
    t.string   "title"
    t.string   "filename"
    t.string   "description"
    t.integer  "song_id"
    t.integer  "instrument_id"
    t.integer  "bpm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",  :precision => 10, :scale => 2
    t.decimal  "rating_avg",    :precision => 10, :scale => 2
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "remember_token"
    t.string   "activation_code"
    t.string   "country"
    t.string   "city"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "photos_url"
    t.string   "blog_url"
    t.string   "myspace_url"
    t.string   "skype"
    t.string   "msn"
    t.boolean  "msn_public",                                                             :default => false
    t.boolean  "skype_public",                                                           :default => false
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "string",                    :limit => 40
    t.string   "type"
    t.text     "motto"
    t.text     "tastes"
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.integer  "friends_count"
    t.integer  "age"
    t.string   "password_reset_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",                            :precision => 10, :scale => 2
    t.decimal  "rating_avg",                              :precision => 10, :scale => 2
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
