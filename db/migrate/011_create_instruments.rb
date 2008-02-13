class CreateInstruments < ActiveRecord::Migration
  def self.up
    create_table :instruments do |t|
      t.string :description
      t.string :icon
      t.timestamps
    end
  end

  def self.down
    drop_table :instruments
  end
end
