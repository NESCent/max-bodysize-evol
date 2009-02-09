# = School Level Controller
#
# Purpose: To allow adminstrators to manage School Levels
#
class SchoolLevelController < ApplicationController
    
    #
    # Only allow administrators access
    #
    before_filter :authorize_admin


    #
    # Use the admin layout
    #
    layout 'admin'


    #
    # Configure active scaffold to display the School Levels
    #
    active_scaffold :school_level do |config|
      config.actions = [:create,:list,:update,:search]
      config.list.columns = [:name]
      config.update.columns = [:name]
      config.create.columns = [:name]
      config.update.link.page = true
      config.create.link.page = true
    end
  end
  