# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 12) do

  create_table "admins", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approvers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audit_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "record_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bodysizes", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "period_id"
    t.integer  "kingdom_id"
    t.integer  "phylum_id"
    t.string   "class_classification"
    t.string   "order_classification"
    t.string   "family"
    t.string   "genus"
    t.string   "species"
    t.integer  "environment_id"
    t.integer  "motility_id"
    t.integer  "feeding_id"
    t.boolean  "approved",                            :default => false, :null => false
    t.float    "width"
    t.float    "height"
    t.float    "length"
    t.float    "mass"
    t.integer  "formula_id"
    t.string   "picture_filename"
    t.string   "picture_path"
    t.string   "epoch"
    t.string   "stage"
    t.text     "how_estimation_was_achieved"
    t.string   "expert_contacted"
    t.text     "literature_citation"
    t.text     "other_data_source"
    t.text     "confidence_comment"
    t.string   "photo_available"
    t.string   "compiler"
    t.text     "first_description_literature_source"
    t.integer  "confidence_score"
    t.float    "volume"
    t.float    "biovolume"
    t.float    "log10_biovolume"
    t.string   "lithology"
    t.string   "preservation_mode"
    t.string   "location"
    t.string   "formation_location"
    t.string   "member"
    t.string   "bed"
    t.string   "local_environment"
    t.string   "regional_environment"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bodysizes", ["creator_id"], :name => "index_bodysizes_on_creator_id"
  add_index "bodysizes", ["environment_id"], :name => "index_bodysizes_on_environment_id"
  add_index "bodysizes", ["feeding_id"], :name => "index_bodysizes_on_feeding_id"
  add_index "bodysizes", ["formula_id"], :name => "index_bodysizes_on_formula_id"
  add_index "bodysizes", ["kingdom_id"], :name => "index_bodysizes_on_kingdom_id"
  add_index "bodysizes", ["motility_id"], :name => "index_bodysizes_on_motility_id"
  add_index "bodysizes", ["period_id"], :name => "index_bodysizes_on_period_id"
  add_index "bodysizes", ["phylum_id"], :name => "index_bodysizes_on_phylum_id"

  create_table "comments", :force => true do |t|
    t.string   "type"
    t.integer  "owner_id"
    t.integer  "bodysize_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["bodysize_id"], :name => "index_comments_on_bodysize_id"
  add_index "comments", ["owner_id"], :name => "index_comments_on_owner_id"

  create_table "formulas", :force => true do |t|
    t.string   "name"
    t.string   "formula"
    t.boolean  "shared",     :default => false, :null => false
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formulas", ["creator_id"], :name => "index_formulas_on_creator_id"

  create_table "periods", :force => true do |t|
    t.string   "name"
    t.float    "midpoint"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "properties", ["type", "name"], :name => "index_properties_on_name_and_type"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "standard_users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "school_name"
    t.string   "school_level"
    t.integer  "number_of_students_in_class"
    t.string   "nickname"
    t.string   "email_address"
    t.text     "profile_description"
    t.string   "picture_filename"
    t.string   "picture_path"
    t.boolean  "disabled",                    :default => false, :null => false
    t.string   "login"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_view "complete_bodysizes", "SELECT b.id, b.creator_id, b.period_id, b.kingdom_id, b.phylum_id, b.class_classification, b.order_classification, b.family, b.genus, b.species, b.environment_id, b.motility_id, b.feeding_id, b.approved, b.width, b.height, b.length, b.mass, b.formula_id, b.picture_path, b.picture_filename, b.epoch, b.stage, b.how_estimation_was_achieved, b.expert_contacted, b.literature_citation, b.other_data_source, b.confidence_comment, b.photo_available, b.compiler, b.first_description_literature_source, b.confidence_score, b.volume, b.biovolume, b.log10_biovolume, b.lithology, b.preservation_mode, b.location, b.formation_location, b.member, b.bed, b.local_environment, b.regional_environment, b.notes, b.created_at, b.updated_at, p.name, p.midpoint FROM (bodysizes b JOIN periods p ON ((b.period_id = p.id)));", :force => true do |v|
    v.column :id
    v.column :creator_id
    v.column :period_id
    v.column :kingdom_id
    v.column :phylum_id
    v.column :class_classification
    v.column :order_classification
    v.column :family
    v.column :genus
    v.column :species
    v.column :environment_id
    v.column :motility_id
    v.column :feeding_id
    v.column :approved
    v.column :width
    v.column :height
    v.column :length
    v.column :mass
    v.column :formula_id
    v.column :picture_path
    v.column :picture_filename
    v.column :epoch
    v.column :stage
    v.column :how_estimation_was_achieved
    v.column :expert_contacted
    v.column :literature_citation
    v.column :other_data_source
    v.column :confidence_comment
    v.column :photo_available
    v.column :compiler
    v.column :first_description_literature_source
    v.column :confidence_score
    v.column :volume
    v.column :biovolume
    v.column :log10_biovolume
    v.column :lithology
    v.column :preservation_mode
    v.column :location
    v.column :formation_location
    v.column :member
    v.column :bed
    v.column :local_environment
    v.column :regional_environment
    v.column :notes
    v.column :created_at
    v.column :updated_at
    v.column :name
    v.column :midpoint
  end

end
