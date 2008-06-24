class RenamePolymorphicColumnsInAbuses < ActiveRecord::Migration
  def self.up
    rename_column :abuses, :item_id, :abuseable_id
    rename_column :abuses, :item_type, :abuseable_type
  end

  def self.down
    rename_column :abuses, :abuseable_id, :item_id
    rename_column :abuses, :abuseable_type, :item_type
  end
end
