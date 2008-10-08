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
