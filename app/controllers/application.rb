# = Application Controller
#
# ApplicationController provides application-wide methods for controlling the flow
# of the application. This controller provides an "abstract" base class for all of the
# other controllers in the system.
# 
# Note: Filters added to this controller apply to all controllers in the application.
#

class ApplicationController < ActionController::Base
  
  # See ActionController::RequestForgeryProtection for details
   protect_from_forgery :secret => '6d7fad658a0529e04b783c8c329bf848'
  
    
  
 
  
  #
  # Ensure that the user is authorized before loading each page
  #
  before_filter :authorize
  
 #
  # Setup the menus before loading each page
  #
  before_filter :menu_setup
  
  @@anonymous_user=User.new
    
  def current_user
    if @current_logged_in_user
      @current_logged_in_user
    else
      @@anonymous_user
    end
  end
  
  # The following methods are all private
  private
  
  
  def self.anonymous_user
    @@anonymous_user
  end
  
  
  
  # Purpose: To verify the current user is authorized. If the user is not authorized then they are
  # sent to the login page.
  # Input: None
  # Output: 
  # * If the user is authorized, true
  # * If the user is not authorized, issues a redirect and returns false
  def authorize # :doc:
    unless is_authorized || (controller_name=='bodysize' && (action_name=='list' || action_name=='export' || action_name=='index' || action_name=='view' || action_name=='home'|| action_name=='about'))
      logger.debug("No user found")
      session[:original_uri] = request.request_uri if session[:original_uri].blank?      
      flash[:notice] = 'Please log in'
      redirect_to(:controller => 'login', :action => 'login')
      return false
    end
    
    return true
  end

  
  
  # Purpose: To verify the current user is authorized.
  # Input: None
  # Output: 
  # * If the user has logged in, returns the currently logged in user
  # * Otherwise, returns nil
  def is_authorized # :doc:
    logger.debug("Attempting to authorize user with session id: #{session[:user_id]}")
    unless @current_logged_in_user
      @current_logged_in_user = User.find_by_id(session[:user_id])
    end
    
    return @current_logged_in_user
  end
  
  
  
  # Purpose: To verify the current user is authorized as an administrator. If the user is not authorized then they are
  # sent to the login page.
  # Input: None
  # Output: 
  # * If the user is authorized, returns the current user
  # * If the user is not authorized, issues a redirect and returns false
  #
  def authorize_admin # :doc:
    if is_authorized_admin
      return @current_logged_in_user
    else
      flash[:warning] = "You are not authorized to view the requested page"
      redirect_to :controller => :bodysize
      return false
    end
  end
  
  
  
  # Purpose: To verify the current user is authorized as an approver. If the user is not authorized then they are
  # sent to the login page.
  # Input: None
  # Output: 
  # * If the user is authorized, returns the current user
  # * If the user is not authorized, issues a redirect and returns false
  #
  def authorize_approver # :doc:
    if is_authorized_approver
      return @current_logged_in_user
    else
      flash[:warning] = "You are not authorized to view the requested page"
      redirect_to :controller => :bodysize
      return false
    end
  end
  
  
  
  # Purpose: To verify the current user is authorized as an admin.
  # Input: None
  # Output: 
  # * If the user has logged in, returns true
  # * Otherwise, returns false
  def is_authorized_admin # :doc:
    return true if @current_logged_in_user && @current_logged_in_user.is_a?(Admin)
    return false
  end
  
  
  # Purpose: To verify the current user is authorized as an approver.
  # Input: None
  # Output: 
  # * If the user has logged in, returns true
  # * Otherwise, returns false
  def is_authorized_approver # :doc:
    return true if @current_logged_in_user && @current_logged_in_user.is_a?(Approver)
    return false
  end
  
  
  # Purpose: To prepare the drop-down menus for display by including the correct menus for the current user
  # Input: None
  # Output: 
  # * None. The menu structure is stored in @top_menu_items which is eventually used by the view /layouts/before_layout
  def menu_setup # :doc:
    unless @current_logged_in_user
      @current_logged_in_user = User.find_by_id(session[:user_id])
    end
    #top menu setup
    @top_menu_items = []
    @top_menu_items << {:label => 'Home', :controller => 'bodysize', :action => 'home'}
    if !@current_logged_in_user
      @top_menu_items << {:label => 'Login', :controller => 'login', :action => 'index'}
      @top_menu_items << {:label => 'Register', :controller => 'register', :action => 'index'}
      bodysize_menu_items = []
      
      bodysize_menu_items << {:label => 'Browse Records', :controller => 'bodysize', :action => 'list'}
      bodysize_menu_items << {:label => 'Add Records', :controller => 'bodysize', :action => 'new' }
      
      @top_menu_items << {:label => 'Bodysize Records', :controller => 'bodysize', :action => 'list', :menu_items => bodysize_menu_items}
    else
      bodysize_menu_items = []
      
      bodysize_menu_items << {:label => 'Browse Records', :controller => 'bodysize', :action => 'list'}

      if @current_logged_in_user.is_a?(Approver)
        bodysize_menu_items << {:label => 'Unapproved Records', :controller => 'bodysize', :action => 'unapproved'}
      end
      bodysize_menu_items << {:label => 'Add Records', :controller => 'bodysize', :action => 'new' }
      
      @top_menu_items << {:label => 'Bodysize Records', :controller => 'bodysize', :action => 'list', :menu_items => bodysize_menu_items}
      
      profile_menu_items = []
      profile_menu_items << {:label => 'View Profile', :controller => 'profile', :action => 'show'}
      profile_menu_items << {:label => 'Edit Profile', :controller => 'profile', :action => 'edit'}      
      
      @top_menu_items << {:label => 'My Profile', :controller => 'profile', :action => 'show', :menu_items => profile_menu_items}
      
      
      if @current_logged_in_user.is_a?(Admin)
        admin_menu_items = []
        admin_menu_items << {:label => 'Users', :controller => 'user', :action => 'list'}
        admin_menu_items << {:label => 'Kingdoms', :controller => 'kingdom', :action => 'index'}
        admin_menu_items << {:label => 'Phyla', :controller => 'phylum', :action => 'index'}
        admin_menu_items << {:label => 'Periods', :controller => 'period', :action => 'index'}
        admin_menu_items << {:label => 'Environments', :controller => 'environment', :action => 'index'}
        admin_menu_items << {:label => 'Motilities', :controller => 'motility', :action => 'index'}
        admin_menu_items << {:label => 'Formulae', :controller => 'formula', :action => 'index'}
        admin_menu_items << {:label => 'School Levels', :controller => 'school_level', :action => 'list'}
        admin_menu_items << {:label => 'Audit Trail', :controller => 'audit_log', :action => 'index'}
        
        @top_menu_items << {:label => 'System Management', :menu_items => admin_menu_items }
      end
      
     
    end
    
     @top_menu_items << {:label => 'About', :controller => 'bodysize', :action => 'about'}
    # side menu highlighting, currently unused
    session[:menu_setup] ||= Hash.new
    if profile_in_menu?(@side_menu_items)
      #save current profile
      session[:menu_setup] = params
    end
  end
  
  
  
  # Purpose: This method is currently unused. It can be used to assist in creating a side-menu if one is needed.
  # Input: Menu Items
  # Output: None
  def profile_in_menu?(items)
    return nil if items.blank?
    for item in items
      item_hash = { :controller => item[:controller], :action => item[:action] }.merge(item[:params] || Hash.new)
      item_params = {}
      item_hash.each{ |k,v| item_params[k.to_s] = v.to_s }
      
      is_subset = true
      item_params.each { |k,v| is_subset = false if params[k] != v }
      return true if is_subset
      
      return true if profile_in_menu?(item[:submenu])
    end
    return nil
  end
  
  
end
