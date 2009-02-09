# = Formula Controller
#
# Purpose: To allow adminstrators to manage Formulae
#
class FormulaController < ApplicationController
  
  #
  # Only allow administrators access
  #
  before_filter :authorize_admin
    
    
  #
  # Use the admin layout
  #  
  layout 'admin'
  
  
  #
  # Configure active scaffold to display the Formulae
  #
  active_scaffold :formula do |config|
    config.actions = [:create,:list,:update,:search]
    config.list.columns = [:name, :formula, :shared]
    config.update.columns = [:name, :formula, :shared]
    config.create.columns = [:name, :formula, :shared]
    
    config.columns[:shared].form_ui = :checkbox
    config.columns[:shared].label = "Standard Formula"
    
    config.update.link.page = true
    config.create.link.page = true
    
    config.label = "Formulae"
  end
end
