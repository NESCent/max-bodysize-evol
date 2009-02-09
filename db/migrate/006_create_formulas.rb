class CreateFormulas < ActiveRecord::Migration
  def self.up
    create_table :formulas do |t|
      t.column :name,     :string
      t.column :formula,  :string
      t.column :shared, :boolean, :null => false, :default => false
      t.column :creator_id, :integer
      t.timestamps
    end

    add_index(:formulas, :creator_id)
  end

  def self.down
    drop_table :formulas
  end
end
