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

  def self.find_from_collection(collection)
    return [] if collection.empty?

    taggable_type = collection.first.class.name
    self.find(:all, :group => 'tag_id', :conditions =>
               ['taggable_id IN (?) AND taggable_type = ?', collection.map(&:id), taggable_type])
  end
end
