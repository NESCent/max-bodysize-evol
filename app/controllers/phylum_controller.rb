# = Phylum Controller
#
# Purpose: To allow adminstrators to manage Phylums
#
class PhylumController < ApplicationController
  
  #
  # Only allow administrators access
  #
  before_filter :authorize_admin
  
  
  #
  # Use the admin layout
  #
  layout 'admin'
  

  #
  # Configure active scaffold to display the Phylums
  #
  active_scaffold :phylum do |config|
    config.actions = [:create,:list,:update,:search]
    config.list.columns = [:name]
    config.update.columns = [:name]
    config.create.columns = [:name]
    config.update.link.page = true
    config.create.link.page = true
    
    config.label = "Phyla"
  end
end
