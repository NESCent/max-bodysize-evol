# == Schema Information
# Schema version: 12
#
# Table name: users
#
#  id                          :integer         not null, primary key
#  type                        :string(255)
#  first_name                  :string(255)
#  last_name                   :string(255)
#  country                     :string(255)
#  state                       :string(255)
#  city                        :string(255)
#  school_name                 :string(255)
#  school_level_id             :integer
#  number_of_students_in_class :integer
#  nickname                    :string(255)
#  email_address               :string(255)
#  profile_description         :text
#  picture_filename            :string(255)
#  picture_path                :string(255)
#  disabled                    :boolean         not null
#  login                       :string(255)
#  hashed_password             :string(255)
#  salt                        :string(255)
#  created_at                  :datetime
#  updated_at                  :datetime
#


# = Approver
#
# Purpose This class represents an Approver user, which has all the capabilities of a User, with additional access privledges
#
class Approver < User
  
  
  #
  # Purpose: Retrieve all of the formulae that are accessible to the current user
  # Input: None
  # Output: Array of Formulas 
  #
  def accessible_formulas
    return Formula.find(:all)
  end
  
  
  #
  # Purpose: Determine if the current user can edit a particular object
  #
  # Input: Object - The object which the user would like to edit
  # Output: 
  # * True if the user has access the given object
  # * False otherwise
  #
  def can_edit?(thing)
    if thing.class == Bodysize || thing.class == CompleteBodysize
      return true
    end
    
    return false
  end
  
  
end
