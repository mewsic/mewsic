# == Schema Information
# Schema version: 20090312174538
#
# Table name: static_pages
#
#  id         :integer(4)    not null, primary key
#  title      :string(255)   
#  url        :string(255)   
#  body       :text          
#  created_at :datetime      
#  updated_at :datetime      
#

# XXX merge with HelpPage!
class StaticPage < ActiveRecord::Base
  xss_terminate :except => [:title, :body]
  
  validates_presence_of :title, :body, :url

  def to_param
    self.url
  end

  def to_breadcrumb
    self.title
  end

  def self.find_from_param(param)
    if param.to_i > 0
      find(param)
    else
      find_by_url(param) or raise ActiveRecord::RecordNotFound, "Cannot find '#{param}' static page"
    end
  end
end
