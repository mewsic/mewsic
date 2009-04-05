class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  belongs_to :tagger, :polymorphic => true
  validates_presence_of :context

  # Counts top taggings, returing an array of [tag_id, count] elements
  # -vjt
  def self.count_top(options = {})
    self.count(:all, options.merge(:group => 'tag_id', :order => 'count_all DESC'))
  end
end
