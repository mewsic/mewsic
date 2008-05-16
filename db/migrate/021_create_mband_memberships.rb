class CreateMbandMemberships < ActiveRecord::Migration
  def self.up
    create_table :mband_memberships do |t|
      t.integer   :mband_id
      t.integer   :user_id
      t.string    :membership_token
      t.datetime  :accepted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :mband_memberships
  end
end
