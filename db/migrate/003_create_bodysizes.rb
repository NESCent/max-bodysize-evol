class CreateBodysizes < ActiveRecord::Migration
  def self.up
    create_table :bodysizes do |t|
      t.column :creator_id,     :integer
      t.column :period_id,      :integer
      t.column :kingdom_id,     :integer
      t.column :phylum_id,      :integer
      t.column :class_classification,   :string # "class" is a reserved word in Ruby
      t.column :order_classification,   :string # "order" is a reserved word in Postgres
      t.column :family,         :string
      t.column :genus,          :string
      t.column :species,        :string
      t.column :environment_id, :integer
      t.column :motility_id,    :integer
      t.column :feeding_id,     :integer
      t.column :approved,       :boolean, :null => false, :default => false
      t.column :width,          :float
      t.column :height,         :float
      t.column :length,         :float
      t.column :mass,           :float
      t.column :formula_id,     :integer
      t.column :picture_filename,   :string
      t.column :picture_path,   :string
      t.column :epoch,          :string
      t.column :stage,          :string
      t.column :how_estimation_was_achieved, :text
      t.column :expert_contacted,   :string
      t.column :literature_citation,  :text
      t.column :other_data_source,    :text
      t.column :confidence_comment,   :text
      t.column :photo_available,      :string
      t.column :compiler,             :string
      t.column :first_description_literature_source,  :text
      t.column :confidence_score,     :integer
      t.column :volume,            :float
      t.column :biovolume,            :float
      t.column :log10_biovolume,      :float
      t.column :lithology,            :string
      t.column :preservation_mode,    :string
      t.column :location,             :string
      t.column :formation_location,   :string
      t.column :member,               :string
      t.column :bed,                  :string
      t.column :local_environment,    :string
      t.column :regional_environment, :string
      t.column :notes,                :text     
      
      t.timestamps
    end

    add_index(:bodysizes, :creator_id)
    add_index(:bodysizes, :period_id)
    add_index(:bodysizes, :kingdom_id)
    add_index(:bodysizes, :phylum_id)
    add_index(:bodysizes, :environment_id)
    add_index(:bodysizes, :motility_id)
    add_index(:bodysizes, :feeding_id)
    add_index(:bodysizes, :formula_id)
  end

  def self.down
    drop_table :bodysizes
  end
end
