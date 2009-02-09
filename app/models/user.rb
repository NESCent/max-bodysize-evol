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



#
# Required to encrypt passwords
#
require 'digest/sha1'


#
# Required to manipulate files
#
require "ftools"


# = User
# 
# Purpose: Serves as an abstract base class for all other user types in the system. Provides general user functionality.
# 
class User < ActiveRecord::Base
  
  
  #
  # Describe a user's associations
  #
  has_many :comments
  has_many :audit_logs
  has_many :bodysizes, :foreign_key => 'creator_id'
  has_many :complete_bodysizes, :foreign_key => 'creator_id'
  has_many :formulas, :foreign_key => 'creator_id'
  belongs_to :school_level


  #
  # Each user must have a unique email address
  #
  validates_presence_of :email_address
  validates_uniqueness_of :email_address



  #
  # Purpose: After the user is saved, write_file is called to save any uploaded files to disk.
  #
  after_save :write_file
  
  
  #
  # Purpose: After a user is destroyed, all of the user's data files should be deleted
  #
  after_destroy :delete_users_files
  
  
  #
  # Allow access to a password_confirmation field to verify the user has typed their password correctly
  #
  attr_accessor :password_confirmation
  
  
  #
  # Purpose: Verify that the user is valid before saving it
  #
  # Input: None
  # Output: None (Adds errors to the model)
  #
  # Users cannot be saved if they are trying to upload a file that is anything other than JPG, GIF, or PNG.
  #
  def validate
    if !@file_data.blank?
      unless ['jpg','gif','png'].include?(extension.downcase)
        errors.add(:picture_path, "Your profile picture must be in JPG, GIF, or PNG format")
      end
    end
  end
  
  
  #
  # Purpose: Verify that the user is valid before creating it
  #
  # Input: None
  # Output: None (Adds errors to the model)
  #
  # New users cannot be created unless they are given a password, and type the password the same way a second time.
  #
  def validate_on_create
      if self.password.blank?
        errors.add(:password, "is missing")
      end
      if self.password != self.password_confirmation
        errors.add(:password_confirmation, "does not match")
      end
  end
  
  
  
  #
  # Purpose: Provide a text representation of the user
  #
  # Input: None (Uses name)
  # Output: String - A text representation of the user
  #
  def to_s
    return "#{name}"
  end


  #
  # Purpose: Retrieve the user's full name
  #
  # Input: None (uses first_name, and last_name)
  #
  # Output: String - the user's full name
  #
  def name
     return "#{self.first_name} #{self.last_name}"
  end


  #
  # Purpose: Authentication method used in LoginController
  #
  # Input: 
  # * email_address (String) - The email address to use in order to authenticate a user
  # * password (String) - The password the user is trying to use to authenticate
  # 
  # Output: 
  # * The User object that matches the given email address, if the password is valid
  # * nil otherwise
  #
  def self.authenticate(email_address, password)
    user = self.find_by_email_address(email_address)
    if user
      expected_password = encrypted_password(password, user.salt)
      user = nil if user.hashed_password != expected_password
    end
    return user
  end
  
  
  #
  # Purpose: Provide access to read @password, which is an attribute that is not persisted
  # Input: None
  # Output: String - The user's password
  #
  # Note: Since the password is not persisted, this method will only return the user's password when the user is setting
  # or changing their password.
  #
  def password
    return @password
  end
  
  
  #
  # Purpose: Allow a user to set their password. This encrypts the given password and persists the encrypted value.
  #
  # Input: pwd (String) - The value to use as the new password
  # Output: String - The user's new hashed password
  #
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
    
    return self.hashed_password
  end
  
  
  #
  # Purpose: Determine if the current use is enabled
  #
  # Input: None (Uses disabled)
  # Output: 
  # * True if the user is enabled
  # * False if the user is disabled
  #
  def enabled?
    return !self.disabled
  end
  
  
  #
  # Purpose: Concatenate the user's location into a string
  #
  # Input: None (Uses city, state, country)
  # Output:
  # * String - A combination of any of the location values which are set
  #
  def public_location
    places = Array.new
    places << self.city if self.city
    places << self.state if self.state
    places << self.country if self.country
    return places.join(", ")
  end
  
  
  #
  # Purpose: Reset the user's password by setting it to a new random password
  #
  # Input: None
  # Output: The user's new password
  #
  def reset_password
    new_password = random_password
    self.password = new_password
    self.save
    return new_password
  end
  
  
  #
  # Purpose: Create a new random password
  #
  # Input: size (integer) [optional] - The number of charaters to use in the password
  # Output: A random string of length "size", that contains upper-case and lower-case letters, as well as digits
  #
  def random_password(size = 8)
    chars = (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0 O I)
    return (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  
  
  #
  # Purpose: Encrypt a password
  #
  # Input:
  # * password (String) - The password to encrypt
  # * salt (String) - The salt to use to improve encryption
  #
  # Output: The SHA1 encrypted version of the given password
  #
  def self.encrypted_password(password, salt)
    string_to_hash = password + "not_so_random_string" + salt
    return Digest::SHA1.hexdigest(string_to_hash)
  end
  
  
  #
  # Purpose: Create a new salt for password encryption
  #
  # Input: None
  # Output: (String) a new partly random salt string
  #
  def create_new_salt
    return self.salt = self.object_id.to_s + rand.to_s
  end
  
  
  #
  # Purpose: Allow a user to set a picture for their profile.
  # The picture path is stored in the user record, and
  # picture data is stored in a class attribute
  # until the user is saved, at which point the file is 
  # written to disk in the appropriate location.
  #
  # Input: file_data (StringIO) - The file data which makes up the user's picture
  # Output: None (Sets @file_data, and picture_filename)
  #
  def picture=(file_data)
    if !file_data.blank?
      @file_data = file_data
    
      self.picture_filename = "picture.#{extension}"
    end
  end
  
  
  #
  # Purpose: Retrieve the web location of the user's picture
  #
  # Input: None (Uses USER_DATA_WEB_PATH, id, and picture_filename)
  # Output: String - The web path to the user's picture
  #
  def picture_path
    return "#{USER_DATA_WEB_PATH}/#{id}/images/#{self.picture_filename}"
  end
  
  
   #
   # Purpose: Provide an array of Bodysize objects which a particular user can access
   #
   # Input: options (Hash) [optional] - Options include the following possibilities:
   # * page (Integer) - The page number as used by Will Paginate (if nil, or false then all results will be returned)
   # * per_page (Integer) - The number of results to return, as used by Will Paginate
   # * joins - Joins option as used by active record find methods
   # * group - Group option as used by active record find methods
   # * order - Order option as used by active record find methods
   # * conditions - Conditions option as used by active record find methods
   #
   def accessible_bodysize_records(options = {})
     if options[:page]
       return CompleteBodysize.paginate(:all, 
        :joins => options[:joins], 
        :conditions => options[:conditions], 
        :group => options[:group], 
        :order => options[:order], 
        :from => "complete_bodysizes",
        :page => options[:page] || 1,
        :per_page => options[:per_page] || 25)
      else
        return CompleteBodysize.find(:all, 
          :joins => options[:joins], 
          :conditions => options[:conditions], 
          :group => options[:group], 
          :order => options[:order], 
          :from => "complete_bodysizes")
      end
   end
   
   
   
   #
   # Purpose: Retrieve CompleteBodysize records which the user can access
   # 
   # Input: 
   # * conditions (Hash) [optional] - The following keys are used:
   # ** :conditions (String) - A sql condition string to be sent to find_by_sql()
   # * options (Hash) [optional] - Additional options that may be sent include:
   # ** page (Integer) - The page to display as used by Will Paginate (Note: If page is nil or false, all records will be returned)
   # ** per_page (Integer) - The number of records to return at a time, as used by Will Paginate
   #
   # Output: 
   # * an Array of CompleteBodysize records found using the given conditions and options
   #
   def get_complete_records(conditions = {}, options = {})
     if options[:page]
       return CompleteBodysize.paginate_by_sql(conditions[:conditions], :page => options[:page], :per_page => options[:per_page])
     else
      return CompleteBodysize.find_by_sql(conditions[:conditions])
    end
   end
   
  
  
  #
  # Purpose: Retrieve all formulae that are accessible to the user. This method may be over-ridden by sub-classes to change the scope of different user's access
  # 
  # Input: None
  #
  # Output: An Array of Formula objects which the user can use.
  #
  def accessible_formulas
    accessible = Formula.find(:all, :conditions => ["shared=?", true])
    accessible.concat self.formulas
    accessible.uniq!
    return accessible
  end
  
  
  #
  # Purpose: Currently an unimplemented stub - Determine whether the user can access an object
  #
  # Input: thing (Object) - The object to determine if the user can access
  # Output:
  # * True if the user can access the object
  # * False otherwise
  #
  def can_access?(thing)
    if thing.class == Bodysize
    end
    
    return false
  end
  
  
  
  #
  # Purpose: Determine if the user can edit and object
  #
  # Input: thing (Object) - The object to determine if the user can access (currently only supports Bodysize and CompleteBodysize objects)
  # Output:
  # * True if the user can edit the given object
  # * False otherwise
  #
  def can_edit?(thing)
    if thing.class == Bodysize || thing.class == CompleteBodysize
      if self == thing.creator
        return true
      end
    end
    
    return false
  end
  
  
  #
  # Private methods, for internal use
  #
  private
  
  
  #
  # Purpose: Save an uploaded file to this user's storage directory  
  #
  # Input: None (Uses @file_data)
  # Output: None (Writes the file to disk)
  #
  def write_file
    if !@file_data.blank?
      directory = "#{USER_DATA_STORAGE_PATH}/#{id}/images/"
      picture_path = directory + self.picture_filename

      if File.makedirs(directory)
        logger.debug("makedirs ok with #{directory}")
      else
        logger.debug("Could not make directory #{directory}")
      end

      logger.debug("Opening file #{self.picture_path}")
      File.open(picture_path, "wb") do |file|
        logger.debug("Writing to file " + file.path)
        file.write(@file_data.read)
      end
    end
  end
  
  
  #
  # Purpose: Delete all of the files in this user's storage directory
  #
  # Input: None (Uses USER_DATA_STORAGE_PATH, id)
  # Output: None
  #
  # Side Effects: Deletes the user's data storage folder
  #
  def delete_users_files
    FileUtils.rm_rf("#{USER_DATA_STORAGE_PATH}/#{id}")
  end
 
  
  #
  # Purpose: Retrieve the file extension from the file that the user is trying to upload
  #
  # Input: None (Uses @file_data)
  # Output: String - The text after the final period in the uploaded file's filename.
  #
  def extension
    return @file_data.original_filename.split(".").last
  end
  
  
    
end
