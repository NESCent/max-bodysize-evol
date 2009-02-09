class CreateAuditLogs < ActiveRecord::Migration
  def self.up
    create_table :audit_logs do |t|
      t.column :user_id,    :integer
      t.column :record_id,  :integer
      t.column :action,     :string
      t.timestamps
    end
  end

  def self.down
    drop_table :audit_logs
  end
end
