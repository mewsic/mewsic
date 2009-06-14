class ChangeUserAgeInBirthDate < ActiveRecord::Migration
  def self.up
    remove_column :users, :age
    add_column :users, :birth_date, :date
  end

  def self.down
    remove_column :users, :birth_date
    add_column :users, :age, :integer
  end
end
