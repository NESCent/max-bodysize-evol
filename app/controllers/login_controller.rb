# = Login Controller
# Purpose: To control user login and logout
#
class LoginController < ApplicationController
  
  #
  # Authorization is not required to view the login and logout pages
  #
  skip_before_filter :authorize


  #
  # Purpose: allow the default action to be used
  # Input: None
  # Output: A redirect is issued to the login action
  #  
  def index
    redirect_to :action => :login
  end
  

  # 
  # Purpose: Allow users to attempt to login
  # Input: 
  # * the email_adderess (string) parameter is used to find the user that is attempting to login
  # * the password (string) parameter is used to verify that the user is authentic
  # Ouptut: 
  # * If authentication is successful, or the user is aleady logged in, then they are redirected to the bodysize controller,
  # Or their original destination if one is stored in the user's session.
  # * IF authenticaion fails, the login page is displayed again with an error message
  #
  # Side Effects: 
  # * The action is logged in the Audit Log
  # * If the user is redirected to their original_uri destination, the original_uri session value is cleared
  #
  def login
    # If the user is already logged in, send them into the application, rather than requesting authentication again.
    if is_authorized
      logger.debug("User is already logged in")
      redirect_to :controller => :bodysize
      return
    end
    
    # The user is not logged in yet. Reset their session
    session[:user_id] = nil
    
    if request.post?
      user = User.authenticate(params[:email_address], params[:password])
      if user && user.enabled?
        login_user_by_id(user.id)        

        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to( uri || '/bodysize/index' )
        return
      else
        flash[:notice] = 'Invalid username/password combination'
        AuditLog.create(:action => "A user failed to login with the username: #{params[:email_address]}")        
      end
    end
  end

 
  #
  # Purpose: Allow a user to logout
  # Input: None
  # Output: The user is redirected to the login page.
  #
  # Side Effects: The action is logged in the Audit Log
  #
  def logout
    if session[:user_id]
      AuditLog.create(:user_id => session[:user_id], :action => "Logged out")
      session[:user_id] = nil
    end
    flash[:notice] = 'You are now logged out'
    
    redirect_to(:action => 'login')
    return
  end

  
  #
  # Purpose: Allow the user to reset their password.
  # Input: The 'email_address' (string) parameter is used to identify which user will have their password reset
  # Output: An email is sent to the given address notifying the user of their new random password.
  #
  # Side Effects: The given user's password is changed to a new random value.
  #
  def password_reset
    if request.post? && params[:email_address]
      flash[:success] = "Your password has been reset, and emailed to #{params[:email_address]}"
      user = User.find_by_email_address(params[:email_address])
      if user
        new_password = user.reset_password
        email = Emailer.create_password_reset(user, new_password)
        Emailer.deliver(email)
      end
      redirect_to :action => :index
      return
    end
  end
  
  
  #
  # Private methods, for internal use only 
  #
  private
  
  
  #
  # Purpos: Actually log the user in.
  # This method sets the necessary information to allow the system to
  # identify the user and admit them to the correct sections.
  # The action is also logged in the Audit Trail.
  #
  # Input: The id of the user to login.
  # Output: None
  #
  # Side Effects: The action is logged in the audit log
  #
  # NOTE: this method does not verify anything about the current user. It simply allows them to login as the user with the given id.
  def login_user_by_id(user_id)
    session[:user_id] = user_id
    logger.debug("Setting session id to #{session[:user_id]}")
     AuditLog.create(:user_id => user_id, :action => "Logged in")
  end
  
 
end
