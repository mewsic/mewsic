class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer :user_id
      t.text    :body
      t.integer :replies_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
