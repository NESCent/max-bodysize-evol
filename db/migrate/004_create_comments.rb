class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :type,         :string
      t.column :owner_id,     :integer
      t.column :bodysize_id,  :integer
      t.column :comment,      :text
      t.timestamps
    end

    add_index(:comments, :owner_id)
    add_index(:comments, :bodysize_id)
  end

  def self.down
    drop_table :comments
  end
end
