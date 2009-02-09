# == Schema Information
# Schema version: 12
#
# Table name: bodysizes
#
#  id                                  :integer         not null, primary key
#  creator_id                          :integer
#  period_id                           :integer
#  kingdom_id                          :integer
#  phylum_id                           :integer
#  class_classification                :string(255)
#  order_classification                :string(255)
#  family                              :string(255)
#  genus                               :string(255)
#  species                             :string(255)
#  environment_id                      :integer
#  motility_id                         :integer
#  feeding_id                          :integer
#  approved                            :boolean         not null
#  width                               :float
#  height                              :float
#  length                              :float
#  mass                                :float
#  formula_id                          :integer
#  picture_filename                    :string(255)
#  picture_path                        :string(255)
#  epoch                               :string(255)
#  stage                               :string(255)
#  how_estimation_was_achieved         :text
#  expert_contacted                    :string(255)
#  literature_citation                 :text
#  other_data_source                   :text
#  confidence_comment                  :text
#  photo_available                     :string(255)
#  compiler                            :string(255)
#  first_description_literature_source :text
#  confidence_score                    :integer
#  volume                              :float
#  biovolume                           :float
#  log10_biovolume                     :float
#  lithology                           :string(255)
#  preservation_mode                   :string(255)
#  location                            :string(255)
#  formation_location                  :string(255)
#  member                              :string(255)
#  bed                                 :string(255)
#  local_environment                   :string(255)
#  regional_environment                :string(255)
#  notes                               :text
#  created_at                          :datetime
#  updated_at                          :datetime
#



# = Bodysize
#
# Purpose: This class represents a Bodysize object which is central to the Bodysize project.
# Bodysize objects maintain attributes regarding the type, size and location of a record
# As well as book-keeping details regarding people and refernce material associated
# with a particular record.
#
class Bodysize < ActiveRecord::Base
  
  
  #
  # A Bodysize object has a number of attributes which are stored
  # in separate data models. 
  #
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :period
  belongs_to :kingdom
  belongs_to :phylum
  belongs_to :environment
  belongs_to :motility
  belongs_to :formula
  belongs_to :feeding
  has_many :public_comments
  has_many :private_notes
  
  
  #
  # Temporary storage locations, to allow the user to create a new equation
  # when saving a bodysize record.
  #
  attr_accessor :formula_name, :formula_equation
  
  
  
  #
  # Purpose: When a Bodysize record is saved, volume is calculated and saved with the record.
  #
  # Input: None (Uses height, weight, length)
  # Output: None (Sets biovolume and log10_biovolume)
  #
  def before_save
    self.height = 0 if self.height.blank?
    self.width = 0 if self.width.blank?
    self.length = 0 if self.length.blank?
    
    
    ## If the user is creating a new formula, create and save it
    self.set_formula
    
    ## Re-calculate the volume for this record based on the height, width, length, and formula given
    self.calculate_volume
    
  end
  
  
  #
  # Purpose: Ensure that records created or added by approver users are automatically
  # approved
  #
  # Input: None (Uses creator)
  # Output: None (Sets approved)
  #
  def before_create
    if self.creator && self.creator.is_a?(Approver)
      self.approved = true
    end
  end
  
  
  
  #
  # Purpose: When a Bodysize record is successfully saved the image associated with the record
  # is written to disk.
  #
  after_save :write_file
  
  
  #
  # Purpose: Verify the validity of a Bodysize record before allowing it to be saved.
  # Records are considered valid if:
  #
  # * The Bodysize image format is either jpg, gif, or png.
  #
  # Input: None (Uses @file_data)
  # Output: None (Adds errors to the model if validation fails)
  #
  def validate
    if !@file_data.blank?
      unless ['jpg','gif','png'].include?(extension.downcase)
        errors.add(:picture_path, "Your profile picture must be in JPG, GIF, or PNG format")
      end
    end
  end
  
  
  
  #
  # Purpose: Verify the validity of a Bodysize record before allowing it to be created.
  # Records are considered valid if:
  #
  # Verifies that the given biovolume matches the value found by evaluating the given formula. This is currently disabled
  #
  # Input: None
  # Output: None (Adds errors to the model if validation fails)
  #
  def validate_on_create
   # unless validate_accurate_biovolume 
   #   errors.add(:biovolume, "The given biovolume does not match the value obtained by evaluating the given formula")
   # end
  end
  
  
  
  #
  # Purpose: When creating or modifying a record, the user can choose an existing formula or create a new one.
  # If a new one is sent in, this method creates the formula and stores the formula_id
  # in the bodysize record
  #
  # Input: None (Uses formula_name, formula_equation, and creator)
  # Output: None (Sets formula), If errors occur, the are added to the model
  # 
  def set_formula
    if !self.formula_name.blank? && !self.formula_equation.blank?
      self.formula = Formula.create!(:name => self.formula_name, :formula => self.formula_equation, :creator_id => self.creator_id)
      return true
    elsif !self.formula
      self.errors.add(:formula, "Cannot be blank")
      return false
    end
  end

  
  #
  # Purpose: Find the value of this record's formula with the height, width, and length from the record
  # 
  # Input: None (Uses formula, height, width, and length)
  # Output: Float - returns the value of the formula evaluated with the height, width, and length
  #
  def evaluate_formula
    return self.formula.evaluate(:height => self.height, :width => self.width, :length => self.length, :mass =>self.mass)
  end
  
  
  
  #
  # Purpose: Find the volume of the Bodysize record by evaluating the formula for the
  # record, with the height, width, and length.
  #
  # Input: None (Uses formula)
  # Output: None (Sets biovolume, log10_biovolume)
  #
  def calculate_volume
    if self.formula
      result = evaluate_formula
      if result
        self.biovolume = result
        self.log10_biovolume = Math::log10(self.biovolume) if self.biovolume && self.biovolume != 0.0
      end
    end
  end
  
  
  #
  # Purpose: This helper method allows a bodysize record to be converted to a string.
  #
  # Input: None (Uses kingdom, phylum, class_classification, period)
  #
  # Output:
  # * Returns the record as a string if the record has a kingdom, phylum, or class_classification
  # * Returns an empty string otherwise
  #
  def to_s
    return "#{kingdom}, #{phylum}, #{class_classification} (#{period})" if kingdom || phylum || class_classification
    return ""
  end
  
  
  #
  # Purpose: Add a message to the audit log to keep track of changes
  # to the bodysize record.
  #
  # Input: 
  # * user (User) - The user that changed the record
  # * bodysize_before_change (Bodysize) - The bodysize record before the change for comparison purposes
  #
  # Output: 
  # * True if the message was successfully logged
  # * False otherwise
  #
  def log_change(user, bodysize_before_change)
    return AuditLog.log("Modified a bodysize record.", user.id)
  end
  
  
  #
  # Purpose: Provide a options for the possible range of confidence scores
  # for a bodysize record.
  #
  # Input: None
  # Output: An array of options for the confidence score drop-down list
  #
  def self.confidence_score_options
    return (1..10).each { |option| [option, option] }
  end
  
  
  #
  # Purpose: Allow a picture of a record to be added.
  # The picture path is stored in the bodysize record, and
  # picture data is stored in a class attribute
  # until the record is saved, at which point the file is 
  # written to disk in the appropriate location.
  #
  # Input: file_data (UploadedStringIO) - The data from the file that was uploaded
  # Output: None (Sets @file_data and picture_filename)
  #
  def picture=(file_data)
    logger.debug("Setting picture_path")
    if !file_data.blank?
      logger.debug("File data not blank")
      @file_data = file_data
      self.picture_filename = "picture.#{extension}"
    end
  end
  
  
  #
  # Purpose: Retrieve the path to this records picture
  #
  # Input: None (Uses BODYSIZE_DATA_WEB_PATH, id, picture_filename)
  # Output: String - The web based path to this model's picture
  #
  def picture_path
    return "#{BODYSIZE_DATA_WEB_PATH}/#{id}/images/#{self.picture_filename}"
  end
  
  
  #
  # Purpose: Save a file to the bodysize storage directory  
  #
  # Input: None (Uses @file_data)
  # Output: None (Saves the file data to disk)
  #
  def write_file
    logger.debug("Attempting to save bodysize image")
    if !@file_data.blank?
      logger.debug("File data not blank")
      
      directory = "#{BODYSIZE_DATA_STORAGE_PATH}/#{id}/images/"
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
  # Purpose: Delete all of the files stored for this bodysize record
  #
  # Input: None (Uses BODYSIZE_DATA_STORAGE_PATH, id)
  # Output: None
  #
  # Side Effects: Removes the storage folder for the bodysize record
  #
  def delete_bodysize_files
    FileUtils.rm_rf("#{BODYSIZE_DATA_STORAGE_PATH}/#{id}")
  end
  
  
  #
  # Purpose: Get the file extension from the file that is being added to the record.
  #
  # Input: None (Uses @file_data)
  # Output: String - Returns the file extension of a newly uploaded record image
  #
  def extension
    logger.debug("Retreiving extension: #{@file_data.original_filename.split(".").last}")
    return @file_data.original_filename.split(".").last
  end
  
  
  #
  # Purpose: Provide a list of bodysize records which have not been approved.
  #
  # Input: page (Integer) [optional] - The page of results to return when the results are paginated, 
  # If not given or set to nil all unapproved records will be returned
  #
  # Output: An Array of Bodysize objects
  # * Returns all unapproved records if page is set to nil (or not given)
  # * Returns a pageinated set of records form the given page if page is not nil
  #
  def self.unapproved_bodysize_records(page = nil)
    if page == nil
      return Bodysize.find(:all, :conditions => ["approved=?", false], :order => "bodysizes.updated_at DESC")
    else
      return Bodysize.paginate(:all, :conditions => ["approved=?", false], :order => "bodysizes.updated_at DESC", :page => page)
    end
  end
  
  
  #
  # Purpose: Verify that the biovolume for a given record matches the value found when the formula is evaluated
  #
  # Input: None (Uses biovolume, height, width, length, formula)
  # Output: 
  # * True if the biovolume matches the formula evaluation
  # * False if there is a mismatch
  #
  # Note: This validation is currently unused
  #
  def validate_accurate_biovolume(precision = 0.001)
    return true if self.biovolume.blank?
    return (self.biovolume - evaluate_formula).abs <= precision ? true : false
  end
  
  
  
  #
  # Purpose: Retrieve the midpoint of the period for this record
  #
  # Input: None (Uses period)
  # Output: 
  # * (Integer) The midpoint of the period for this record if it has a period
  # * Nil otherwise
  #
  def period_midpoint
    return period.midpoint if period
  end
  
    
end
