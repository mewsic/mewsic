class Mlab < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :mixable, :polymorphic => true
  
end
