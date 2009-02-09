namespace :db do
  desc "Load seed data fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y. Seed data will be loaded from fixture files in the /db/seed/ directory."
  task :seed => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'db', 'seed', '*.{yml,csv}'))).each do |fixture_file|
      Fixtures.create_fixtures('db/seed', File.basename(fixture_file, '.*'))
    end
  end
end