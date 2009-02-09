# = Audit Log Controller
#
# Purpose: To handle requests related to the Audit Log
#
class AuditLogController < ApplicationController
  
  #
  # Only allow administrators access
  #
  before_filter :authorize_admin


  #
  # Use the admin layout
  #
  layout 'admin'
  
  
  #
  # Configure active scaffold to display the Audit Log correctly
  #
  active_scaffold :audit_log do |config|
    config.actions = [:list,:search]
    config.columns = [:user, :action, :created_at]
    config.list.columns = [:user, :action, :bodysize, :created_at]
    config.columns[:created_at].label = "Time"
    config.columns[:bodysize].label = "Bodysize Record"
    
    config.list.sorting = { :created_at => :desc }
    
    config.label = "Audit Trail"
  end

end
