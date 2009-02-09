class CreateCompleteBodysizesView < ActiveRecord::Migration
    def self.up
        create_view :complete_bodysizes, "SELECT b.id, b.creator_id, b.period_id, b.kingdom_id, b.phylum_id, b.class_classification, b.order_classification, b.family, b.genus, b.species, b.environment_id, b.motility_id, b.feeding_id, b.approved, b.width, b.height, b.length, b.mass, b.formula_id, b.picture_path, b.picture_filename, b.epoch, b.stage, b.how_estimation_was_achieved, b.expert_contacted, b.literature_citation, b.other_data_source, b.confidence_comment, b.photo_available, b.compiler, b.first_description_literature_source, b.confidence_score, b.volume, b.biovolume, b.log10_biovolume, b.lithology, b.preservation_mode, b.location, b.formation_location, b.member, b.bed, b.local_environment, b.regional_environment, b.notes, b.created_at, b.updated_at, p.name, p.midpoint FROM bodysizes AS b JOIN periods AS p ON b.period_id = p.id" do |t|
                t.column :id
                t.column :creator_id
                t.column :period_id
                t.column :kingdom_id
                t.column :phylum_id
                t.column :class_classification
                t.column :order_classification
                t.column :family
                t.column :genus
                t.column :species
                t.column :environment_id
                t.column :motility_id
                t.column :feeding_id
                t.column :approved
                t.column :width
                t.column :height
                t.column :length
                t.column :mass
                t.column :formula_id
                t.column :picture_path
                t.column :picture_filename
                t.column :epoch
                t.column :stage
                t.column :how_estimation_was_achieved
                t.column :expert_contacted
                t.column :literature_citation
                t.column :other_data_source
                t.column :confidence_comment
                t.column :photo_available
                t.column :compiler
                t.column :first_description_literature_source
                t.column :confidence_score
                t.column :volume
                t.column :biovolume
                t.column :log10_biovolume
                t.column :lithology
                t.column :preservation_mode
                t.column :location
                t.column :formation_location
                t.column :member
                t.column :bed
                t.column :local_environment
                t.column :regional_environment
                t.column :notes
                t.column :created_at
                t.column :updated_at
                t.column :name
                t.column :midpoint
            end
    end

    def self.down
        drop_view :complete_bodysizes
    end
end

