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


# = Admin
# 
# Purpose: This class represents an Administrator user, which is a user who has the capabilities of an Approver User
# as well as additional access to necessary parts of the system.
#
class Admin < Approver
end
