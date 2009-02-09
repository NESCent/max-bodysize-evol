# = Emailer
# 
# Purpose: Allow email messages to be sent from the bodysize application
#
class Emailer < ActionMailer::Base

  #
  # Purpose: Email a new password to a user
  #
  # Input:
  # * recipient (User) - The user to send the new password to
  # * password (String) - The user's new password
  # * sent_at (Time) [optional] - The time to mark the message as sent at
  #
  # Output: None
  #
  # Side Effects: An email message is sent to the user with the user's new password
  #
  def password_reset(recipient, password, sent_at = Time.now)
        @subject = "Bodysize - Password Reset"
        @recipients = recipient.email_address
        @from = 'password-manager@#{SERVER_NAME}'
        @sent_on = sent_at
        @body = {:recipient => recipient, :password => password, :server => SERVER_NAME}
        @headers = {}
     end



end
