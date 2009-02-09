# == Schema Information
# Schema version: 12
#
# Table name: audit_logs
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  record_id  :integer
#  action     :string(255)
#  created_at :datetime
#  updated_at :datetime
#


#
# Purpose: This class represents an Audit Log entry, which provides a means to track
# the actions which have been performed in the system.
#
class AuditLog < ActiveRecord::Base
  
  
  #
  # Most audit log entries are associated with the user who performed the action
  # that is being logged.
  #
  belongs_to :user
  
  
  #
  # Each audit log entry must have a description of the action performed.
  #
  validates_presence_of :action
  
  
  #
  # Some Audit Log entries are associated with a particular record
  #
  belongs_to :bodysize, :foreign_key => "record_id"
  
  
  #
  # Purpose: To help simplify logging of actions
  #
  # Input: 
  # * message (String) - The action that occurred
  # * user_id (Integer) [optional] - The id of the user who performed the action
  # * record_id (Integer) [optional] - The bodysize record id associated with the action
  #
  # Output: 
  # * True if the message was successfully logged
  # * False otherwise
  #
  def self.log(message, user_id = nil, record_id = nil)
    return AuditLog.create(:user_id => user_id, :record_id => record_id, :action => message)
  end
  
  
end
