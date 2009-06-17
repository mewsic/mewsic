class CreateGears < ActiveRecord::Migration
  def self.up
    create_table :gears do |t|
      t.string :brand
      t.string :model

      t.references :user
      t.references :instrument

      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :gears
  end
end
