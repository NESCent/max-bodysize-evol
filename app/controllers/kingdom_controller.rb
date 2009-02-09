# = Kingdom Controller
#
# Purpose: To allow adminstrators to manage Kingdoms
#
class KingdomController < ApplicationController
  
  #
  # Only allow administrators access
  #
  before_filter :authorize_admin
  
  
  #
  # Use the admin layout
  #
  layout 'admin'
  

  #
  # Configure active scaffold to display the Kingdoms
  #
  active_scaffold :kingdom do |config|
    config.actions = [:create,:list,:update,:search]
    config.list.columns = [:name]
    config.update.columns = [:name]
    config.create.columns = [:name]
    config.update.link.page = true
    config.create.link.page = true
  end

end
