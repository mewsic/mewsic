# == Schema Information
# Schema version: 20090312174538
#
# Table name: replies
#
#  id           :integer(4)    not null, primary key
#  answer_id    :integer(4)    
#  user_id      :integer(4)    
#  body         :text          
#  created_at   :datetime      
#  updated_at   :datetime      
#  rating_count :integer(4)    
#  rating_total :decimal(10, 2 
#  rating_avg   :decimal(10, 2 
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: replies
#
#  id           :integer(11)   not null, primary key
#  answer_id    :integer(11)   
#  user_id      :integer(11)   
#  body         :text          
#  created_at   :datetime      
#  updated_at   :datetime      
#  rating_count :integer(11)   
#  rating_total :decimal(10, 2 
#  rating_avg   :decimal(10, 2 
#
# == Description
#
# A Reply is much similar to an Answer, but it serves as answers' child to make
# users able to reply to open questions. A Reply can be rated, it uses the
# <tt>medlar_acts_as_rated</tt> plugin, with a range from <tt>0</tt> to <tt>5</tt>.
# See https://ulisse.adelao.it/rdoc/myousica/plugins/medlar_acts_as_rated for more
# information on the plugin.
#
# == Associations
#
# * <b>belongs_to</b> an Answer, with a <tt>counter_cache</tt>
# * <b>belongs_to</b> an User, with a <tt>counter_cache</tt>
#
# == Validations
# 
# * <b>validates_presence_of</b> <tt>body</tt>
#
# == Callbacks
#
# * <b>after_create</b> +update_answer_last_activity_at+
#
class Reply < ActiveRecord::Base
  belongs_to :answer, :counter_cache => true
  belongs_to :user, :counter_cache => true
  
  acts_as_rated :rating_range => 0..5 
  
  attr_accessible :body
  
  after_create :update_answer_last_activity_at
  
  validates_presence_of :body    

  # Checks whether this Reply can be rated by the user passed as first parameter.
  # A Reply cannot be rated by its owner.
  #
  def rateable_by?(user)
    self.user_id != user.id
  end

private

  # Updates parent answer's <tt>last_activity_at</tt> attribute, setting it to
  # the creation date of this Reply, in order to keep the Answer open.
  #
  def update_answer_last_activity_at
    self.answer.update_attribute(:last_activity_at, self.created_at)
  end
  
end
