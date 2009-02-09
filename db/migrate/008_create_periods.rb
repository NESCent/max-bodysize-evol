class CreatePeriods < ActiveRecord::Migration
  def self.up
    create_table :periods do |t|
      t.column :name,   :string
      t.column :midpoint,  :float
      t.timestamps
    end
  end

  def self.down
    drop_table :periods
  end
end
