# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: band_members
#
#  id             :integer(11)   not null, primary key
#  nickname       :string(20)    the nickname of this member
#  instrument_id  :integer(11)   the instrument played by this member
#  user_id        :integer(11)   the owner Band of this member
#  linked_user_id :integer(11)   the optional linked user to this member
#  country        :string(45)    the country of this member
#  created_at     :datetime      
#  updated_at     :datetime      
#
# == Description
#
# This model represents a Band member, that can be associated only to a Band. They
# can be of two kinds: "bare" members, who've got a nickname, an instrument, an avatar
# and a country or "linked" members to actual myousica users.
# If this member is linked, the <tt>facade</tt> plugin makes the <tt>country</tt>,
# <tt>avatars</tt> and <tt>nickname</tt> methods return data from the linked user record.
# See https://ulisse.adelao.it/rdoc/myousica/plugins/facade/.
#
# == Associations
# 
# Belongs to a Band, to the Instrument this member plays in the Band and to an optional
# linked myousica User (<tt>linked_user</tt>). Has many +Avatar+s.
#
# == Validations
#
# Validates presence of <tt>nickname</tt> if this member is not linked to an User, 
# <tt>linked_user_id</tt> if it is. Validates presence of the <tt>instrument_id</tt>
# and a valid associated Instrument.
#
class BandMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :instrument
  belongs_to :linked_user, :class_name => 'User' 
  has_many   :avatars, :as => :pictureable, :dependent => :destroy
  
  attr_accessible :nickname, :country, :instrument_id, :linked_user_id

  validates_presence_of :nickname, :if => Proc.new { |m| m.linked_user_id.blank? }
  validates_presence_of :linked_user_id, :if => Proc.new { |m| m.nickname.blank? }

  validates_presence_of :instrument_id, :user_id
  validates_associated :instrument, :user, :linked_user

  facade :nickname, :country, :avatars, :with => Proc.new { |m| m.linked_to_myousica_user? ? m.linked_user : m }

  # Returns true if this member is linked to a Myousica user
  def linked_to_myousica_user?
    !self.linked_user_id.blank?
  end

  # Removes all the avatars of the member and adds an existing one whose id is passed
  # as the first parameter
  def update_avatar(id)
    self.avatars.destroy_all
    self.avatars << Avatar.find(id)
  end

  # Links this member to an existing myousica user, by erasing the <tt>nickname</tt> and <tt>country</tt>
  # attributes, destroying all the avatars and setting the <tt>linked_user_id</tt> attribute to the id
  # of the user passed as the first parameter
  def link_to(user)
    self.unlink!
    self.nickname = self.country = nil
    self.avatars_without_facade.each(&:destroy)
    self.linked_user_id = user.id
  end

  # Unlinks this member from the linked myousica user, by setting the <tt>linked_user_id</tt> to <tt>nil</tt>.
  def unlink!
    self.linked_user_id = nil
  end

end
