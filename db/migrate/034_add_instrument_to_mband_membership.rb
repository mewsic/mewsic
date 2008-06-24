class AddInstrumentToMbandMembership < ActiveRecord::Migration
  def self.up
    add_column :mband_memberships, :instrument_id, :integer
  end

  def self.down
    remove_column :mband_memberships, :instrument_id
  end
end
