class Tag < ActiveRecord::Base
  has_many :taggings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end

  # Count top taggings, and construct an array of Tag objects sorted by taggings count.
  # -vjt
  def self.find_top(options = {})
    tag_ids = Tagging.count_top(options).map(&:first)
    self.find(tag_ids).sort_by { |tag| tag_ids.index(tag.id) }
  end

  def self.find_from_collection(collection)
    tag_ids = Tagging.find_from_collection(collection).map(&:tag_id)
    self.find(tag_ids)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
end
