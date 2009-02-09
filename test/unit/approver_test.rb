require File.dirname(__FILE__) + '/../test_helper'

class ApproverTest < ActiveSupport::TestCase
  fixtures :users, :bodysizes, :properties, :periods, :formulas
  
  def test_create_new
    user = Approver.create(
      :email_address => "testing@dev.null",
      :first_name => "Helen",
      :password => "test",
      :password_confirmation => "test"
      )
    assert user.id > 0
    assert_equal "testing@dev.null", user.email_address
    assert_equal "Approver", user.type
    assert user.is_a?(Approver)
  end
  
  
  def test_accessible_bodysize_records
    
  end
  
  
end
