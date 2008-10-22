# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: messages
#
#  id                :integer(11)   not null, primary key
#  sender_id         :integer(11)   
#  recipient_id      :integer(11)   
#  sender_deleted    :boolean(1)    
#  recipient_deleted :boolean(1)    
#  subject           :string(255)   
#  body              :text          
#  read_at           :datetime      
#  created_at        :datetime      
#  updated_at        :datetime      
#
# == Description
#
# This model represents a private message between two users. Uses the <tt>simple_private_messages</tt> plugin.
# See its documentation for details (https://ulisse.adelao.it/rdoc/myousica/plugins/simple_private_messages).
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>body</tt>
# * <b>validate</b> +recipient_must_exist+
# * <b>validate</b> +recipient_must_be_different_than_sender+
# * <b>xss_terminate</b> sanitizes <tt>subject</tt> and <tt>body</tt>
#   See https://ulisse.adelao.it/rdoc/myousica/plugins/xss_terminate.
#
class Message < ActiveRecord::Base

  is_private_message
  
  attr_accessor :to
  
  validates_presence_of :body

  validate :recipient_must_exist
  validate :recipient_must_be_different_than_sender

  # XXX body should be sanitized too, e.g by using textile
  # to format messages. XSS could occur in private messages
  # otherwise :(. -vjt
  xss_terminate :except => [:body], :sanitize => [:subject]
  
private

  # Verifies that the recipient is not nil
  # 
  def recipient_must_exist
    if self.recipient.nil?
      errors.add_to_base("recipient doesn't exist")
    end
  end
    
  # Verifies that sender and recipient must be different
  #
  def recipient_must_be_different_than_sender
    if self.recipient == self.sender
      errors.add_to_base("sender and recipient must be different")
    end
  end
  
end
