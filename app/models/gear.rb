class Gear < ActiveRecord::Base
  belongs_to :user
  belongs_to :instrument

  validates_presence_of :brand, :model, :user, :instrument
  validates_associated :user, :instrument

  def self.sort(ids)
    update_all(
      ['position = FIND_IN_SET(id, ?)', ids.join(',')],
      { :id => ids }
    )
  end
end
