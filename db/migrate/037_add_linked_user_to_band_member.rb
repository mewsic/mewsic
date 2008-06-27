class AddLinkedUserToBandMember < ActiveRecord::Migration
  def self.up
    add_column :band_members, :linked_user_id, :integer
  end

  def self.down
    remove_column :band_members, :linked_user_id
  end
end
