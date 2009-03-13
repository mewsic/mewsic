# == Schema Information
# Schema version: 20090312174538
#
# Table name: profile_views
#
#  id         :integer(4)    not null, primary key
#  user_id    :integer(4)    
#  viewer     :string(32)    
#  created_at :datetime      
#  updated_at :datetime      
#

# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: profile_views
#
#  id         :integer(11)   not null, primary key
#  user_id    :integer(11)   
#  viewer     :string(32)    
#  created_at :datetime      
#  updated_at :datetime      
#
# == Description
#
# Profile views collection works using the <tt>__mt</tt> tracking cookie
# (see ApplicationController#set_tracking_cookie) that is stored into the
# <tt>viewer</tt> attribute.
#
# Profile viewers must be unique in the <tt>user_id</tt> scope, so a viewer
# can increment the counter only once.
#
# Each hour, a Cron job runs the +count_and_cleanup+ method to collect all
# unique visitors and update the User <tt>profile_views</tt> counter.
#
class ProfileView < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :viewer
  validates_associated :user
  validates_uniqueness_of :viewer, :scope => :user_id

  def self.count_and_cleanup
    ProfileView.transaction do
      ProfileView.count(:all, :group => :user_id).each do |user_id, count|
        User.update_counters user_id, :profile_views => count
      end
      ProfileView.delete_all
    end
  end
end
