# = Profile Controller
#
# Purpose: Allow users to manage their own profile, and view other users' profiles
#
class ProfileController < ApplicationController
  
  
  #
  # Purpose: Allow users to modify their profile. Users can modify their own profile, and Administrators can modify any other user's profile
  # Input: the 'id' (int) parameter is used to identify the user who's profile will be modified
  # Output: The @user, and @school_levels variables are given the appropriate values to allow the user to be modified.
  #
  # If no user is given, then the current logged in user's profile is displayed
  #
  def edit
    @user = User.find_by_id(params[:id]) if params[:id]
    
    # If no user was given, default to the current user's own profile
    @user = @current_logged_in_user unless @user
    
    @school_levels = SchoolLevel.options
    
    if @user && (@user == @current_logged_in_user || @current_logged_in_user.is_a?(Admin))
      if request.post?
        if @user.update_attributes(params[:user])
          flash[:success] = "Your changes have been saved!"
        end
      end
    else
      flash[:warning] = "You do not have permission to modify this user"
      redirect_to :action => :show, :id => params[:id]
      return
    end
  end
  
  
  
  #
  # Purpose: Display a user's profile
  # Input: the 'id' (int) parameter is used to idenfity which user's profile should be displayed
  # Output: The @user variable is set to the requested user
  #
  # If no user is given, then the current logged in user's profile is displayed
  #
  def show
    @user = User.find_by_id(params[:id]) || User.find_by_id(@current_logged_in_user.id)
    
    if @user.disabled
      @user = nil
      flash[:warning] = "The specified user could not be found."
      redirect_to :controller => :bodysize
      return
    end
    
  end
  
  
  #
  # Purpose: Allow a user to remove their profile picture. Administrators can also remove pictures from any user.
  # Input: the 'id' (int) parameter is used to idenfity which user's picture will be removed
  # Output: The @user variable is set to the requested user
  # A partial template is rendered with the option to upload a new picture
  #
  def remove_picture
    @user = User.find_by_id(params[:id])
    
    if @user && (@user == @current_logged_in_user || @current_logged_in_user.is_a?(Admin))
      @user.picture_filename = nil
      @user.save
      
      
      render :partial => "picture_edit", :locals => {:user => @user}
    end
  end
  
  
end
