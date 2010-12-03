class Addqtype < ActiveRecord::Migration
  def self.up
    add_column :questions, :qtype, :text
  end

  def self.down
    remove_column :questions, :qtype
  end
end
