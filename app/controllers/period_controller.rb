# = Period Controller
#
# Purpose: To allow adminstrators to manage Periods
#
class PeriodController < ApplicationController
  
  #
  # Only allow administrators access
  #
  before_filter :authorize_admin


  #
  # Use the admin layout
  #
  layout 'admin'
  

  #
  # Configure active scaffold to display the Periods
  #
  active_scaffold :period do |config|
    config.actions = [:create,:list,:update,:search]
    config.list.columns = [:name, :midpoint]
    config.update.columns = [:name, :midpoint]
    config.create.columns = [:name, :midpoint]
    config.update.link.page = true
    config.create.link.page = true
  end
end
