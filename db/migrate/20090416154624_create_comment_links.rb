class CreateCommentLinks < ActiveRecord::Migration
  def self.up
    create_table :comment_attachments do |t|
      t.references :comment
      t.references :attachment, :polymorphic => true
    end
  end

  def self.down
    drop_table :comment_attachments
  end
end
