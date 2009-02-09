# == Schema Information
# Schema version: 12
#
# Table name: complete_bodysizes
#
#  id                                  :integer         primary key
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
#  approved                            :boolean
#  width                               :float
#  height                              :float
#  length                              :float
#  mass                                :float
#  formula_id                          :integer
#  picture_path                        :string(255)
#  picture_filename                    :string(255)
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
#  name                                :string(255)
#  midpoint                            :float
#



# = Complete Bodysize
# 
# Purpose: Simplify the joining of multiple models to gather all of the data in a Bodysize record 
#
class CompleteBodysize < ActiveRecord::Base
  
  #
  # Describe bodysize associations
  #
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :period
  belongs_to :kingdom
  belongs_to :phylum
  belongs_to :environment
  belongs_to :motility
  belongs_to :formula
  belongs_to :feeding
end
