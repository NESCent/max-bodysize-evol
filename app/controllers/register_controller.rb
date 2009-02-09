# = Register Controller
#
# Purpose: Allow new users to register for the system
#
class RegisterController < LoginController

  #
  # Use the profile layout and views
  #
  layout 'profile'


  #
  # Purpose: Prepare a template for new users to fill in.
  # Input: None
  # Output:
  # * The @user variable is set with default values as a new StandardUser
  # * The @school_levels variable is set with the drop-down options for all of the school levels in the system
  # * The profile editing template is rendered
  #
  def index
    @user = StandardUser.new
    @user.country = "United States of America" # Default value
    @school_levels = SchoolLevel.options
    render :template => "profile/edit"
  end
  
  
  #
  # Purpose: Save the new registration information
  # Input:
  # * The user parameter contains each of the pieces of data required to create a new user.
  # Output: None
  #
  # Side Effects: The action is logged in the audit log.
  #
  def edit
    @user = StandardUser.new
    @school_levels = SchoolLevel.options
    if request.post?
      if @user.update_attributes(params[:user])
        login_user_by_id(@user.id)
        AuditLog.create(:user_id => @user.id, :action => "Registered a new account")
        redirect_to :action => :introduction
        return
      end
    end
    
    render :template => "profile/edit"
  end
  
  
  #
  # Purpose: Display introduction information when a new user registers
  # Input:
  # * None
  # Output: None
  #
  def introduction
  end
  

end
