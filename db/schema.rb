# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090616184156) do

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
    t.integer  "comments_count",                                  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",     :precision => 10, :scale => 2
    t.decimal  "rating_avg",       :precision => 10, :scale => 2
    t.boolean  "closed",                                          :default => false, :null => false
    t.datetime "last_activity_at"
    t.boolean  "delta",                                           :default => false
  end

  create_table "comment_attachments", :force => true do |t|
    t.integer "comment_id"
    t.integer "attachment_id"
    t.string  "attachment_type"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 60
    t.text     "body"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.integer  "rating_count"
    t.decimal  "rating_total",                   :precision => 10, :scale => 2
    t.decimal  "rating_avg",                     :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "featurings", :force => true do |t|
    t.integer  "song_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "friend_id",   :null => false
    t.datetime "created_at"
    t.datetime "accepted_at"
  end

  create_table "gears", :force => true do |t|
    t.string   "brand"
    t.string   "model"
    t.integer  "user_id"
    t.integer  "instrument_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "position"
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
    t.decimal  "rating_total",   :precision => 10, :scale => 2
    t.decimal  "rating_avg",     :precision => 10, :scale => 2
    t.integer  "members_count",                                 :default => 0
    t.boolean  "delta",                                         :default => false
    t.integer  "comments_count",                                :default => 0
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",    :default => false
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

  create_table "profile_views", :force => true do |t|
    t.integer  "user_id"
    t.string   "viewer",     :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer "rater_id"
    t.integer "rated_id"
    t.string  "rated_type"
    t.decimal "rating",     :precision => 10, :scale => 2
  end

  add_index "ratings", ["rated_type", "rated_id"], :name => "index_ratings_on_rated_type_and_rated_id"
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"

  create_table "songs", :force => true do |t|
    t.string   "title",          :limit => 60
    t.string   "author",         :limit => 60
    t.text     "description"
    t.string   "filename",       :limit => 64
    t.integer  "user_id"
    t.integer  "seconds",                                                     :default => 0
    t.integer  "listened_times",                                              :default => 0
    t.integer  "status",                                                      :default => -2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",                 :precision => 10, :scale => 2
    t.decimal  "rating_avg",                   :precision => 10, :scale => 2
    t.string   "user_type",      :limit => 10
    t.boolean  "delta",                                                       :default => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "comments_count",                                              :default => 0
  end

  create_table "static_pages", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tracks", :force => true do |t|
    t.string   "title",                                                       :default => "Untitled"
    t.string   "filename",       :limit => 64
    t.text     "description"
    t.integer  "instrument_id"
    t.integer  "listened_times",                                              :default => 0
    t.integer  "seconds",                                                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",                 :precision => 10, :scale => 2
    t.decimal  "rating_avg",                   :precision => 10, :scale => 2
    t.integer  "user_id"
    t.string   "author",         :limit => 60
    t.integer  "status",                                                      :default => -2
    t.boolean  "delta",                                                       :default => false
    t.integer  "comments_count",                                              :default => 0
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
    t.text     "biography"
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.integer  "friends_count"
    t.string   "password_reset_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total",                            :precision => 10, :scale => 2
    t.decimal  "rating_avg",                              :precision => 10, :scale => 2
    t.integer  "writings_count",                                                         :default => 0
    t.boolean  "is_admin",                                                               :default => false
    t.string   "status",                    :limit => 3,                                 :default => "off"
    t.boolean  "name_public",                                                            :default => false
    t.string   "multitrack_token",          :limit => 64
    t.boolean  "podcast_public",                                                         :default => true
    t.integer  "profile_views",                                                          :default => 0
    t.boolean  "delta",                                                                  :default => false
    t.integer  "comments_count",                                                         :default => 0
    t.string   "facebook_uid"
    t.date     "birth_date"
    t.text     "influences_genres"
    t.text     "influences_artists"
    t.text     "influences_movies"
    t.text     "influences_books"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "videos", :force => true do |t|
    t.string   "name",        :limit => 32
    t.string   "description"
    t.string   "filename",    :limit => 64
    t.string   "poster",      :limit => 64
    t.string   "highres",     :limit => 64
    t.string   "thumb",       :limit => 64
    t.integer  "length"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
