class ChangeMixVolumeToFloat < ActiveRecord::Migration
  def self.up
    change_column :mixes, :volume, :float, :default => 1.0
    Mix.reset_column_information
    Mix.find(:all, :conditions => 'volume > 1.0').each do |m|
      m.volume /= 100.0
      m.save or puts "Failed to save mix #{m.id}"
    end
  end

  def self.down
    change_column :mixes, :volume, :integer, :default => 1
  end
end
