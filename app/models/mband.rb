# == Schema Information
# Schema version: 21
#
# Table name: mbands
#
#  id            :integer(11)   not null, primary key
#  name          :string(255)   
#  photos_url    :string(255)   
#  blog_url      :string(255)   
#  myspace_url   :string(255)   
#  motto         :text          
#  tastes        :text          
#  friends_count :integer(11)   
#  user_id       :integer(11)   
#  created_at    :datetime      
#  updated_at    :datetime      
#

class Mband < ActiveRecord::Base
  
  acts_as_rated :rating_range => 0..5
  
  has_many :avatars, :as => :pictureable  
  belongs_to :leader, :class_name => 'User', :foreign_key => 'user_id'
  
  attr_accessible :name
  
  validates_presence_of :name
  
  def to_breadcrumb
    self.name
  end
  
end
