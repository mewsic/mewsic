class CommentAttachment < ActiveRecord::Base
  belongs_to :comment
  belongs_to :attachment, :polymorphic => true
end
