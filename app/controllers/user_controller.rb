# = User Controller
#
# Purpose: To allow adminstrators to manage Users
#
class UserController < ApplicationController


  #
  # Only allow administrators access
  #
  before_filter :authorize_admin
  
  
  #
  # Use the admin layout
  #
  layout 'admin'
  
  # Setup active scaffold to allow users to be listed, created, and edited
  active_scaffold :user do |config|
    config.actions = [:create,:list,:update,:search]
    config.columns[:disabled].form_ui = :checkbox
    config.columns[:state].form_ui = :usa_state
    config.list.columns = [:first_name, :last_name, :email_address]
    
  #  Users should be modified through the Profile page to the extent that they can be  
  #  config.update.columns = [:type, :first_name, :last_name, :email_address, :city, :state, :country, :school_name, :school_level, :number_of_students_in_class, :profile_description, :disabled]
  #  config.create.columns = [:type, :first_name, :last_name, :email_address, :password, :password_confirmation, :city, :state, :country, :school_name, :school_level, :number_of_students_in_class, :profile_description, :disabled]
    config.update.columns = [:type, :disabled]
    config.create.columns = [:first_name, :last_name, :email_address, :password, :password_confirmation, :type, :disabled]

    config.update.link.page = true
    config.create.link.page = true
    
    config.columns[:type].form_ui = :select
    config.columns[:country].form_ui = :country
    
    config.columns[:school_level].form_ui = :select
    config.columns[:school_level].sort_by :sql => "id"
    
    profile = ActiveScaffold::DataStructures::ActionLink.new('edit', 
                 :label => 'Profile', 
                 :type => :record, 
                 :page => true,
                 :controller => 'profile', 
                 :position => false)
       config.action_links << profile
  end
end
