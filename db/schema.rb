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

ActiveRecord::Schema.define(:version => 9) do

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

  create_table "mixes", :force => true do |t|
    t.integer  "song_id"
    t.integer  "track_id"
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
    t.integer  "user_id"
    t.integer  "genre_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",    :precision => 10, :scale => 2
    t.decimal  "rating_avg",      :precision => 10, :scale => 2
  end

  create_table "tracks", :force => true do |t|
    t.string   "title"
    t.integer  "song_id"
    t.integer  "genre_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total", :precision => 10, :scale => 2
    t.decimal  "rating_avg",   :precision => 10, :scale => 2
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
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.text     "motto"
    t.text     "tastes"
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.integer  "friends_count"
    t.integer  "age"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",                            :precision => 10, :scale => 2
    t.decimal  "rating_avg",                              :precision => 10, :scale => 2
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
