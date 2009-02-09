# == Schema Information
# Schema version: 12
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


#
# Purpose: Represents bodysize comments and notes.
#
class Comment < ActiveRecord::Base
  
  #
  # Purpose: A comment belongs to the user who created the comment.
  #
  belongs_to :owner, :class_name => "User"
  
  
  #
  # Purpose: A comment belongs to the bodysize for which the comment was written.
  #
  belongs_to :bodysize
  
  
  #
  # Purpose: convert a comment into a string
  #
  # Input: None (Uses comment)
  # Output: String - The comment
  #
  def to_s
    "#{comment}"
  end
  
end
