class AddClosedToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :closed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :answers, :closed
  end
end
