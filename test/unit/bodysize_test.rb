require File.dirname(__FILE__) + '/../test_helper'

class BodysizeTest < ActiveSupport::TestCase
   fixtures :users, :bodysizes, :properties, :periods, :formulas


## This test is disabled until we know which attributes will be required
#  def test_invalid_with_empty_attributes
#    bodysize = Bodysize.new
#    assert !bodysize.valid?, "Bodysize is not valid with empty attributes"
#    assert bodysize.errors.invalid?(:creator), "creator is required"
#    assert bodysize.errors.invalid?(:height), "height is required"
#    assert bodysize.errors.invalid?(:width), "width is required"
#    assert bodysize.errors.invalid?(:length), "length is required"
#    assert bodysize.errors.invalid?(:kingdom), "kingdom is required"
#    assert bodysize.errors.invalid?(:phylum), "phylum is required"
#    assert bodysize.errors.invalid?(:class_classification), "class_classification is required"
#  end


  def test_create_new
    bodysize = Bodysize.create(
      :creator => users(:standarduser),
      :period => periods(:Neogene),
      :kingdom => properties(:Plantae),
      :phylum => properties(:Equisetophyta), 
      :environment => properties(:Env_Marine),
      :motility => properties(:Motility_S),
      :feeding => properties(:Feeding_Hc),
      :class_classification => "Happy",
      :width => 3.2,
      :height => 4.6,
      :length => 7.3,
      :mass => 22.11,
      :formula => formulas(:Rectangular_Prism),
      :epoch => "Long ago",
      :stage => "Three",
      :expert_contacted => "Mary Lively", 
      :literature_citation => "A book",
      :other_data_source => "The internet",
      :confidence_comment => "Very confident",
      :photo_available => "No",
      :compiler => "Steve Lively",
      :first_description_literature_source => "An old book", 
      :confidence_score => 9,
      :lithology => "Limestone",
      :preservation_mode => "Mummy",
      :location => "Egypt",
      :formation_location => "Somewhere", 
      :member => "Something",
      :bed => "Yes",
      :local_environment => "Hot", 
      :regional_environment => "Humid",
      :notes => "This is a test"
     )
    assert bodysize.valid?
    assert bodysize.id > 0
    assert_equal("Testy McGee", bodysize.creator.name)
    assert_equal("H*W*L", bodysize.formula.formula)
  end
  
  
  def test_validations
    
  end
  
  
  def test_retrieve_unapproved_records
    
  end
  
  
  def test_upload_incorrect_filetype
    
  end
  
  
  def test_upload_image
    
  end
  
  
  def test_volume_set_upon_save
    
  end
  
  
end
