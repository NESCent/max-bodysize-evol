require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :bodysizes, :properties, :periods, :formulas

  def test_invalid_with_empty_attributes
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:email_address)
    assert user.errors.invalid?(:password)
  end


  def test_uniqueness_constraints
    user = User.new(:email_address => "test@dev.null")
    assert !user.valid?
    assert user.errors.invalid?(:email_address)
  end

  
  def test_passwords_must_match
    user = User.new(
      :email_address => "testing@dev.null",
      :password => "password",
      :password_confirmation => "different"
      )
      
    assert !user.valid?
    assert user.errors.invalid?(:password_confirmation)
  end
 
end
