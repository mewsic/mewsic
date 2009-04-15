class AddInstrumentCroppingCoordinates < ActiveRecord::Migration
  def self.up
    add_column :instruments, :position, :integer
  end

  def self.down
    remove_column :instruments, :position, :integer
  end
end
