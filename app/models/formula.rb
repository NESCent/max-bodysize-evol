# == Schema Information
# Schema version: 12
#
# Table name: formulas
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  formula    :string(255)
#  shared     :boolean         not null
#  creator_id :integer
#  created_at :datetime
#  updated_at :datetime
#


# = Formula
#
# Purpose: This class represents a formula which is used to estimate the volume
# of a bodysize for the record.
#
class Formula < ActiveRecord::Base
  
  #
  # Set default formula evaluation options
  #
  DEFAULT_EVALUATION_OPTIONS = {:height => nil, :width => nil, :length => nil, :mass => nil}
  
  
  #
  # Define the characters that are allowed in the formula
  #
  ALLOWED_CHARACTERS_REGEXP = /^([\d\sHWLM\+\*\^\.\(\)-]*)$/


  #
  # Allow reading of the compiled attribute
  #
  attr_reader :compiled
  
  
  #
  # A formula may be associated with many bodysize records
  #
  has_many :bodysizes
  
  
  #
  # A formula belongs to the person who created the formula
  #
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  
  
  #
  # Each formula must have a name and a formula
  #
  validates_presence_of :name, :formula
  
  
  #
  # Each formula must have a unique name
  #
  validates_uniqueness_of :name, :message => "must be unique"
  
  
  #
  # Verify that the formula is valid before saving.
  # A formula may contain:
  #
  # * H - The letter 'H', which will be replaced with the height of the specimen when evaluating the formula.
  # * W - The letter 'W', which will be replaced with the width of the specimen when evaluating the formula.
  # * L - The letter 'L', which will be replaced with the length of the specimen when evaluating the formula.
  # * + - A plus sign
  # * * - An astrix, which will perform multiplication
  # * ^ - A caret, which will perform exponentiation
  # * Floating point numbers - Such as "3", "3.0", or "-0.1049"
  validates_format_of :formula, :with => ALLOWED_CHARACTERS_REGEXP
  
  
  #
  # Run a test evaluation of the formula to ensure it is valid mathematically
  # Bodysize records will not be able to be saved with an invalid formula
  # But invalid formulae could be created by the administrator without warning,
  # unless this function is enabled
  #
  # TODO: this should to be included but is commented for now
  #def validate
  #    # Try to evaluate the formula to ensure the formula is valid
  #    self.evaluate(:height => 1, :width => 1, :length => 1)
  #end



  #
  # Purpose: Evaluate this formula
  #
  # Input: options (Hash) [optional] - Options include:
  # * height (Float) - The height to use when evaluating the formula
  # * width (Float) - The width to use when evaluating the formula
  # * length (Float) - The length to use when evaluating the formula
  #
  # Output: 
  # * If successful, the value of the formula is returned
  # * Otherwise a SyntaxError is raised
  #
  def evaluate(options = Hash.new())
      options = DEFAULT_EVALUATION_OPTIONS.merge(options)

      # Replace H, W, or L with passed in values.
      # If H, W, or L don't exist then it returns an unaltered string which
      # allows them to be optional.
      formula = self.formula.gsub('H', options[:height].to_s)
      formula = formula.gsub('W', options[:width].to_s)
      formula = formula.gsub('L', options[:length].to_s)
      formula = formula.gsub('M', options[:mass].to_s)

      # Replace operators with correct notation.
      formula = formula.gsub('^', '**')

      # TODO: a '.' must be preceded by an integer
      if formula =~ /^.*?\D\.\d.*?$/
          raise "A '.' must be preceeded by a digit."
      end

      @compiled = formula
      begin
          result = eval(formula)
      rescue SyntaxError
          raise "Cannot evaluate: #{self.formula}"
      else
          return result
      end
  end
  
  
  
  #
  # Purpose: Retrieve shared formulae in a format that can be used to create a select drop down
  # 
  # Input: None
  # Output: An array of formulae in drop-down option format
  #
  def self.shared_formula_options
    return Formula.find(:all, :order => 'id', :conditions => ["shared=?", true]).map { |item| item.to_option }
  end
  
  
  #
  # Purpose: Convert a formula to an easy to read label
  #
  # Input: None (Uses name, forumla)
  # Output: String - A text representation of the formula
  #
  def to_label
    return "#{self.name} (#{self.formula})"
  end
  
  
  #
  # Purpose: Convert a formula to an easy to read string
  #
  # Input: None (Uses name, forumla)
  # Output: String - A text representation of the formula
  #
  def to_s
    return to_label
  end
  

  #
  # Purpose: Convert a formula to a format that can be used to create a select drop-down
  #
  # Input: None (Uses to_label, id)
  # Output: An array in which the first value is the label for the formula, and the second value is the id of the formula
  #
  def to_option
    [self.to_label, self.id]
  end
  
end
