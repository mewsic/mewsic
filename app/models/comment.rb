class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true, :counter_cache => :comments_count
  belongs_to :user, :counter_cache => :writings_count

  acts_as_rated :rating_range => 0..5

  attr_accessible :title, :body

  validates_presence_of :user, :body

  # A comment cannot be rated by its author
  #
  def rateable_by?(user)
    self.user.rateable_by?(user)
  end

end
