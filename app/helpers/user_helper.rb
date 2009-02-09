# = User Helper
#
# Purpose: Create helper methods which will be available to all User templates in the application.
#
module UserHelper

  #
  # Purpose: Provide values to the active scaffold field for User Type.
  # Input:
  # * record (User) - The User record being modified
  # * input_name
  #
  # Output: 
  # * A drop-down box with the necessary values
  #
  # Note: See active scaffold documentation for further details
  #
  def type_form_column(record, input_name)
    select :record, :type, {"Standard User" => "StandardUser", "Approver" => "Approver", "Admin" => "Admin"}
  end

end
