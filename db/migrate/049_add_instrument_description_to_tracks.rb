class AddInstrumentDescriptionToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :instrument_description, :string
  end

  def self.down
    remove_column :tracks, :instrument_description
  end
end
