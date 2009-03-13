# == Schema Information
# Schema version: 20090312174538
#
# Table name: mlabs
#
#  id           :integer(4)    not null, primary key
#  user_id      :integer(4)    
#  mixable_id   :integer(4)    
#  mixable_type :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
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
# == Description
#
# An Mlab is an element into an User's "My List". Because the list is saved upon sessions
# and is shared between the XHTML interface and the multitrack SWF, it is stored into the
# database.
#
# Because the my list is loaded into the widget at every refresh, these finders are called
# very often, so the queries have been optimized as such. The interface should be fixed,
# though, by caching the output.
#
# == Associations and validations
#
# Belongs to an User and to a <tt>mixable</tt> object, that can be either a Song or a Track.
# Validates the presence of the <tt>mixable</tt> and the <tt>user_id</tt>.
#
class Mlab < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :mixable, :polymorphic => true
  
  validates_presence_of :mixable, :user_id

  # Finds the my list contents for the specified <tt>user</tt>.
  # Uses +find_songs+ and +find_tracks+ first, and then calls +fetch_avatar_for+
  # on every <tt>mixable</tt>.
  #
  def self.find_my_list_items_for(user)
    songs  = find_songs  :all, :conditions => ['mlabs.user_id = ?', user.id]
    tracks = find_tracks :all, :conditions => ['mlabs.user_id = ?', user.id]
    (songs + tracks).map { |mixable| fetch_avatar_for(mixable) }
  end

  # Returns a single my list item, as customized Song and Track instances (see +find_songs+
  # and +find_tracks+).
  #
  # * <tt>user</tt>: owner
  # * <tt>type</tt>: either <tt>track</tt> or <tt>song</tt>
  # * <tt>id</tt>: mixable id
  #
  def self.find_my_list_item_for(user, type, id)
    fetch_avatar_for(
      case type
        when 'track' then find_tracks id, :conditions => ['mlabs.user_id = ?', user.id]
        when 'song'  then find_songs  id, :conditions => ['mlabs.user_id = ?', user.id]
        else raise ActiveRecord::RecordNotFound
      end)
  end

  private
    # Fills the <tt>avatar</tt> attribute of the passed mixable (Song or Track) with the
    # public filename of the owner Avatar.
    #
    def self.fetch_avatar_for(mixable)
      avatar = Picture.find(mixable.attributes.delete('avatar_id')).
        public_filename(:icon) rescue '/images/default_avatars/avatar_icon.gif'

      mixable.attributes.update('avatar' => avatar)
    end

    # Returns a Song collection with attributes optimized for the My List scroller, to
    # optimize loading time. The following attributes are fetched and ordered by Mlab
    # creation time.
    #
    # * <tt>mlabs_id</tt>: Mlab id
    # * <tt>type</tt>: "song"
    # * <tt>id</tt>: Song id
    # * <tt>title</tt>: Song title
    # * <tt>original_author</tt>: Song original author
    # * <tt>user_id</tt>: Song creator User id
    # * <tt>user_login</tt>: creator User login
    # * <tt>avatar_id</tt>: Avatar id
    #
    def self.find_songs(what = :all, options = {})
      Song.find(what, options.merge(
        :select => 'mlabs.id AS mlab_id, "song" AS type, songs.id, songs.title, songs.original_author, users.id AS user_id, users.login AS user_login, pictures.id AS avatar_id',
        :joins => 'LEFT OUTER JOIN mlabs ON mlabs.mixable_id = songs.id AND mlabs.mixable_type = "Song" LEFT OUTER JOIN users ON users.id = songs.user_id LEFT OUTER JOIN pictures ON pictures.pictureable_id = songs.user_id AND pictures.pictureable_type = "User" AND pictures.type = "Avatar"',
        :order => 'mlabs.created_at'))
    end

    # Returns a Track collection with attributes optimized for the My List scroller, to
    # optimize loading time. The following attributes are fetched and ordered by Mlab
    # creation time.
    #
    # * <tt>mlabs_id</tt>: Mlab id
    # * <tt>type</tt>: "track"
    # * <tt>id</tt>: Track id
    # * <tt>title</tt>: Track title
    # * <tt>original_author</tt>: Track's parent Song original author
    # * <tt>user_id</tt>: Track creator User id
    # * <tt>user_login</tt>: creator User login
    # * <tt>avatar_id</tt>: Avatar id
    #
    def self.find_tracks(what = :all, options = {})
      Track.find(what, options.merge(
        :select => 'mlabs.id AS mlab_id, "track" AS type, tracks.id, tracks.title, songs.original_author, users.id AS user_id, users.login AS user_login, pictures.id AS avatar_id',
        :joins => 'LEFT OUTER JOIN mlabs ON mlabs.mixable_id = tracks.id AND mlabs.mixable_type = "Track" LEFT OUTER JOIN users ON users.id = tracks.user_id inner join songs ON songs.id = tracks.song_id LEFT OUTER JOIN pictures ON pictures.pictureable_id = tracks.user_id AND pictures.pictureable_type = "User" AND pictures.type = "Avatar"',
        :order => 'mlabs.created_at'))
    end
end
