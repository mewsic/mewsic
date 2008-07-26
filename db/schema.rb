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

ActiveRecord::Schema.define(:version => 54) do

  create_table "abuses", :force => true do |t|
    t.integer  "abuseable_id"
    t.string   "abuseable_type"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "topic"
  end

  create_table "answers", :force => true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.integer  "replies_count",                                   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",     :precision => 10, :scale => 2
    t.decimal  "rating_avg",       :precision => 10, :scale => 2
    t.boolean  "closed",                                          :default => false, :null => false
    t.datetime "last_activity_at"
  end

  create_table "band_members", :force => true do |t|
    t.string   "nickname",       :limit => 20
    t.integer  "instrument_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country",        :limit => 45
    t.integer  "linked_user_id"
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

  create_table "help_pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  create_table "instrument_categories", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instruments", :force => true do |t|
    t.string   "description"
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  create_table "mband_memberships", :force => true do |t|
    t.integer  "mband_id"
    t.integer  "user_id"
    t.string   "membership_token"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instrument_id"
  end

  create_table "mbands", :force => true do |t|
    t.string   "name"
    t.string   "photos_url"
    t.string   "blog_url"
    t.string   "myspace_url"
    t.text     "motto"
    t.text     "tastes"
    t.integer  "friends_count"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",  :precision => 10, :scale => 2
    t.decimal  "rating_avg",    :precision => 10, :scale => 2
    t.integer  "members_count",                                :default => 0
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
    t.float    "volume",     :default => 1.0
    t.integer  "loop"
    t.float    "balance",    :default => 0.0
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
    t.integer  "pictureable_id"
    t.string   "pictureable_type"
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
    t.integer  "rating_count"
    t.decimal  "rating_total", :precision => 10, :scale => 2
    t.decimal  "rating_avg",   :precision => 10, :scale => 2
  end

  create_table "songs", :force => true do |t|
    t.string   "title",           :limit => 60
    t.string   "original_author", :limit => 60
    t.string   "description"
    t.string   "tone",            :limit => 2
    t.string   "filename",        :limit => 64
    t.integer  "user_id"
    t.integer  "genre_id"
    t.integer  "bpm"
    t.integer  "seconds",                                                      :default => 0
    t.integer  "listened_times",                                               :default => 0
    t.boolean  "published",                                                    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",                  :precision => 10, :scale => 2
    t.decimal  "rating_avg",                    :precision => 10, :scale => 2
    t.integer  "key"
  end

  create_table "static_pages", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracks", :force => true do |t|
    t.string   "title",                  :limit => 60
    t.string   "filename",               :limit => 64
    t.string   "description"
    t.string   "tonality",               :limit => 2,                                 :default => "C"
    t.integer  "song_id"
    t.integer  "instrument_id"
    t.integer  "listened_times",                                                      :default => 0
    t.integer  "seconds",                                                             :default => 0
    t.integer  "bpm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",                         :precision => 10, :scale => 2
    t.decimal  "rating_avg",                           :precision => 10, :scale => 2
    t.boolean  "idea",                                                                :default => false, :null => false
    t.integer  "user_id"
    t.string   "instrument_description"
    t.integer  "key"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "remember_token"
    t.string   "activation_code"
    t.string   "country",                   :limit => 45
    t.string   "city",                      :limit => 40
    t.string   "first_name",                :limit => 32
    t.string   "last_name",                 :limit => 32
    t.string   "gender",                    :limit => 20
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
    t.integer  "replies_count",                                                          :default => 0
    t.string   "nickname",                  :limit => 20
    t.boolean  "is_admin",                                                               :default => false
    t.string   "status",                    :limit => 3,                                 :default => "off"
    t.boolean  "name_public",                                                            :default => false
    t.string   "multitrack_token",          :limit => 64
    t.boolean  "podcast_public",                                                         :default => true
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
