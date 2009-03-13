class RenameSiblingsToMixables < ActiveRecord::Migration
  def self.up
    remove_column :mixes, :loop
    remove_column :mixes, :balance
    remove_column :mixes, :time_shift
  end

  def self.down
    add_column :mixes, :loop, :integer
    add_column :mixes, :balance, :float
    add_column :mixes, :time_shift, :integer
  end
end
