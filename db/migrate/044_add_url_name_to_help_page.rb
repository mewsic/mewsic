class AddUrlNameToHelpPage < ActiveRecord::Migration
  def self.up
    add_column :help_pages, :url, :string
  end

  def self.down
    remove_column :help_pages, :url
  end
end
