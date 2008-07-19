# == Schema Information
# Schema version: 46
#
# Table name: mlabs
#
#  id           :integer(11)   not null, primary key
#  user_id      :integer(11)   
#  mixable_id   :integer(11)   
#  mixable_type :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Mlab < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :mixable, :polymorphic => true
  
  validates_presence_of :mixable

  def self.find_my_list_items_for(user)
    songs  = find_songs  :all, :conditions => ['mlabs.user_id = ?', user.id]
    tracks = find_tracks :all, :conditions => ['mlabs.user_id = ?', user.id]
    (songs + tracks).map { |mixable| item_attributes_of(mixable) }
  end

  def self.find_my_list_item_for(user, type, id)
    item_attributes_of(
      case type
        when 'track' then find_tracks id, :conditions => ['mlabs.user_id = ?', user.id]
        when 'song'  then find_songs  id, :conditions => ['mlabs.user_id = ?', user.id]
        else raise ActiveRecord::RecordNotFound
      end)
  end

  private
    def self.item_attributes_of(mixable)
      avatar = Picture.find(mixable.attributes.delete('avatar_id')).
        public_filename(:icon) rescue '/images/default_avatars/avatar_icon.gif'

      mixable.attributes.update('avatar' => avatar)
    end

    def self.find_songs(what = :all, options = {})
      Song.find(what, options.merge(
        :select => 'mlabs.id AS mlab_id, "song" AS type, songs.id, songs.title, songs.original_author, users.id AS user_id, users.login AS user_login, genres.name AS genre_name, pictures.filename AS avatar',
        :joins => 'LEFT OUTER JOIN mlabs ON mlabs.mixable_id = songs.id AND mlabs.mixable_type = "Song" LEFT OUTER JOIN users ON users.id = songs.user_id LEFT OUTER JOIN genres ON genres.id = songs.genre_id LEFT OUTER JOIN pictures ON pictures.pictureable_id = songs.user_id AND pictures.pictureable_type = "User" AND pictures.type = "Avatar"',
        :order => 'mlabs.created_at'))
    end

    def self.find_tracks(what = :all, options = {})
      Track.find(what, options.merge(
        :select => 'mlabs.id AS mlab_id, "track" AS type, tracks.id, tracks.title, songs.original_author, users.id AS user_id, users.login AS user_login, genres.name AS genre_name, pictures.filename AS avatar',
        :joins => 'LEFT OUTER JOIN mlabs ON mlabs.mixable_id = tracks.id AND mlabs.mixable_type = "Track" LEFT OUTER JOIN users ON users.id = tracks.user_id inner join songs ON songs.id = tracks.song_id LEFT OUTER JOIN genres ON genres.id = songs.genre_id LEFT OUTER JOIN pictures ON pictures.pictureable_id = songs.user_id AND pictures.pictureable_type = "User" AND pictures.type = "Avatar"',
        :order => 'mlabs.created_at'))
    end
end
