# == Schema Information
# Schema version: 26
#
# Table name: instruments
#
#  id          :integer(11)   not null, primary key
#  description :string(255)   
#  icon        :string(255)   
#  category_id :integer(11)
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Instrument < ActiveRecord::Base
  has_many :tracks
  belongs_to :category, :class_name => 'InstrumentCategory'

  validates_presence_of :description
  validates_uniqueness_of :description, :case_sensitive => false

  validates_presence_of :category_id
  validates_associated :category

  before_save :set_default_icon

  private

    def set_default_icon
      self.icon ||= "instruments/#{self.description.downcase.gsub(/\s/, '_')}.png"
    end

end
