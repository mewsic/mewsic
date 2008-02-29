class CreateMlabs < ActiveRecord::Migration
  def self.up
    create_table :mlabs do |t|
      t.integer :user_id
      t.integer :mixable_id
      t.string :mixable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :mlabs
  end
end
