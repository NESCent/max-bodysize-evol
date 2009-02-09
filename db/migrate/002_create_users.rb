class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :type,             :string
      t.column :first_name,       :string
      t.column :last_name,        :string
      t.column :country,          :string
      t.column :state,            :string
      t.column :city,             :string
      t.column :school_name,       :string
      t.column :school_level_id,     :integer
      t.column :number_of_students_in_class, :integer
      t.column :nickname,         :string
      t.column :email_address,    :string
      t.column :profile_description,  :text
      t.column :picture_filename,     :string
      t.column :picture_path,     :string
      t.column :disabled,         :boolean, :null => false, :default => false
      t.column :login,           :string
      t.column :hashed_password, :string
      t.column :salt,            :string
      t.column :teacher_updates,  :boolean, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
