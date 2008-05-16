class CreateHelpPages < ActiveRecord::Migration
  def self.up
    create_table :help_pages do |t|
      t.string :title
      t.text :body
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :help_pages
  end
end
