class AddLastActivityAtToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :last_activity_at, :datetime
  end

  def self.down
    remove_column :answers, :last_activity_at
  end
end
