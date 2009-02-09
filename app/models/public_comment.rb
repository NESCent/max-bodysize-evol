# == Schema Information
# Schema version: 15
#
# Table name: comments
#
#  id          :integer         not null, primary key
#  type        :string(255)
#  owner_id    :integer
#  bodysize_id :integer
#  comment     :text
#  created_at  :datetime
#  updated_at  :datetime
#


# = Public Comment
#
# Purpose: Allow users to comment on bodysize records. The functionality for this model comes from it's 
# parent class.
#
#
class PublicComment < Comment
end
