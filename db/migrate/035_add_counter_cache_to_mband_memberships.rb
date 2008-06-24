class AddCounterCacheToMbandMemberships < ActiveRecord::Migration
  def self.up
    add_column :mbands, :members_count, :integer, :default => 0
    Mband.find(:all).each do |m|
      m.members_count = m.members.count
      m.save!
    end
  end

  def self.down
    remove_column :mbands, :members_count
  end
end
