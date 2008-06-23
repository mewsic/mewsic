class Abuse < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :abuseable, :polymorphic => true
  
end
