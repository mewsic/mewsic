class InstrumentCategory < ActiveRecord::Base
  has_many :instruments, :foreign_key => 'category_id'
  validates_presence_of :description
end
