# == Schema Information
# Schema version: 20090614112927
#
# Table name: comments
#
#  id               :integer(4)    not null, primary key
#  title            :string(60)    
#  body             :text          
#  commentable_id   :integer(4)    
#  commentable_type :string(255)   
#  user_id          :integer(4)    
#  rating_count     :integer(4)    
#  rating_total     :decimal(10, 2 
#  rating_avg       :decimal(10, 2 
#  created_at       :datetime      
#  updated_at       :datetime      
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true, :counter_cache => :comments_count
  belongs_to :user, :counter_cache => :writings_count

  has_many_polymorphs :attachments, :from => [:songs, :tracks, :photos],
    :through => :comment_attachment

  acts_as_rated :rating_range => 0..5

  attr_accessible :title, :body

  validates_presence_of :user, :body

  # A comment cannot be rated by its author
  #
  def rateable_by?(user)
    self.user.rateable_by?(user)
  end

end
