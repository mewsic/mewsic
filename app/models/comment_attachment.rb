# == Schema Information
# Schema version: 20090615124539
#
# Table name: comment_attachments
#
#  id              :integer(4)    not null, primary key
#  comment_id      :integer(4)    
#  attachment_id   :integer(4)    
#  attachment_type :string(255)   
#

class CommentAttachment < ActiveRecord::Base
  belongs_to :comment
  belongs_to :attachment, :polymorphic => true
end
