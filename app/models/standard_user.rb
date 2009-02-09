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



# = Standard User
#
# Purpose: This class represents a type of user who can self-register, and who has
# limited permissions.
#
class StandardUser < User
  
  
  #
  # Purpose: Provide an array of Bodysize objects which a particular Approver uesr can access
  #
  # Input: options (Hash) [optional] - Any options given are passed on to the parent class
  # * conditions (Array) - The conditions option is an array of conditions in the standard rails style ["sql query = ?", value1]
  # Any conditions that are given will limit the result set to records which are both accessible and meet the given conditions.
  #
  # Output: An Array of Bodysize objects which the user can access and which meet all given conditions
  #
  #
  def accessible_bodysize_records(options = {})
    conditions = options[:conditions] || Array.new
    
    if conditions[0].blank?
      conditions[0] = "approved=? OR creator_id=?"
    else
      conditions[0] = "(#{conditions[0]}) AND (approved=? OR creator_id=?)"
    end
    
    conditions << true
    conditions << self.id
    
    options[:conditions] = conditions
    return super(options)
  end

  
end
