class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.column :type,   :string
      t.column :name,   :string
      t.timestamps
    end

    add_index(:properties, [:name, :type])
  end

  def self.down
    drop_table :properties
  end
end
