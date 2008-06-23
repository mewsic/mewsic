class AddTopicToAbuses < ActiveRecord::Migration
  def self.up
    add_column :abuses, :topic, :string
  end

  def self.down
    remove_column :abuses, :topic
  end
end
