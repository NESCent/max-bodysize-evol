require File.dirname(__FILE__) + '/../test_helper'

class StandardUserTest < ActiveSupport::TestCase
  fixtures :users, :bodysizes, :properties, :periods, :formulas

  def test_create_new
    user = StandardUser.create(
      :email_address => "testing@dev.null",
      :first_name => "Helen",
      :password => "test",
      :password_confirmation => "test"
      )
    assert user.id > 0
    assert_equal "testing@dev.null", user.email_address, "Email address is correct"
    assert_equal "StandardUser", user.type, "User has type StandardUser"
    assert user.is_a?(StandardUser), "User is a StandardUser"
  end
  
  
  def test_accessible_bodysize_records
    user = users(:standarduser)
    records = user.accessible_bodysize_records
    
    assert_equal 2, records.length, "Fixture contain two records this user should be able to access"
    
    records.each do |record|
      assert((record.creator == user || record.approved), "User is record's creator, or record is approved")
    end
  end
  
end
