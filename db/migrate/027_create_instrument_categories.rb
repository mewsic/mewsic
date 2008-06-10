class CreateInstrumentCategories < ActiveRecord::Migration
  def self.up
    create_table :instrument_categories do |t|
      t.string :description
      t.timestamps
    end

    add_column :instruments, :category_id, :integer
  end

  def self.down
    drop_table :instrument_categories

    remove_column :instruments, :category_id
  end
end
