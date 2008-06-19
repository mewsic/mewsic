class Abuse < ActiveRecord::Base
  
  belongs_to :abuseable, :polymorphic => true
  
end
