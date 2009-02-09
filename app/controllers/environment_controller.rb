# = Environment Controller
#
# Purpose: To allow adminstrators to manage Environments
#
class EnvironmentController < ApplicationController

  #
  # Only allow administrators access
  #
  before_filter :authorize_admin
  
  
  #
  # Use the admin layout
  #
  layout 'admin'
  
  
  #
  # Configure active scaffold to display the Environments correctly
  #
  active_scaffold :environment do |config|
    config.actions = [:create,:list,:update,:search]
    config.list.columns = [:name]
    config.update.columns = [:name]
    config.create.columns = [:name]
    config.update.link.page = true
    config.create.link.page = true
  end

end
