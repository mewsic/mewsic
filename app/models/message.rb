class Message < ActiveRecord::Base

  is_private_message
  
  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  attr_accessor :to
  
  validate :recipient_must_exist
  
private

  def recipient_must_exist
    if self.recipient.nil?
      errors.add_to_base("recipient doesn't exist")
    end
  end
    
  
end