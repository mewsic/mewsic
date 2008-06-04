# == Schema Information
# Schema version: 26
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

class Message < ActiveRecord::Base

  is_private_message
  
  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  attr_accessor :to
  
  validates_presence_of :body

  validate :recipient_must_exist
  validate :recipient_must_be_different_than_sender

  # XXX body should be sanitized too, e.g by using textile
  # to format messages. XSS could occur in private messages
  # otherwise :(. -vjt
  xss_terminate :except => [:body], :sanitize => [:subject]
  
private

  def recipient_must_exist
    if self.recipient.nil?
      errors.add_to_base("recipient doesn't exist")
    end
  end
    

  def recipient_must_be_different_than_sender
    if self.recipient == self.sender
      errors.add_to_base("sender and recipient must be different")
    end
  end
  
end
