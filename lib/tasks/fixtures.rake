namespace :fixtures do
  
  desc "list fixtures available in db/migrate/dev_data"
  task :list => :environment do
    list_fixtures
  end
  
  desc "load specified fixture from db/migrate/dev_data with MODEL=ModelClass"
  task :load => :environment do
    require 'active_record/fixtures'
    require 'finder_helper'
    error_check_and_process{load_fixture(Object.const_get(ENV['MODEL']))}
  end
  
  desc "load all initial database fixtures (in db/bootstrap/*.yml) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
  task :load_all => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(Rails.root, 'db', 'migrate', 'dev_data', '*.{yml}'))).each do |fixture_file|
      Fixtures.create_fixtures('db/migrate/dev_data', File.basename(fixture_file, '.*'))
    end
  end
   
  desc "purge all data from table with MODEL=ModelClass"
  task :purge => :environment do
    error_check_and_process{purge_fixture(Object.const_get(ENV['MODEL']))}
  end
  
  desc "reload all data from table with MODEL=ModelClass"
  task :reload => :environment do
    require 'active_record/fixtures'
    require 'finder_helper'
    error_check_and_process do
      ENV['MODEL'].split(/\s*,\s*/).each do |model|
        purge_fixture(Object.const_get(model))
        load_fixture(Object.const_get(model))
      end
    end
  end
  
  def error_check_and_process
    if ENV['MODEL']
      yield
    else
      puts "Please specify a model name from the avialable ones listed below:"
      list_fixtures
    end
  end
  
  def purge_fixture(model_class)
    model_class.delete_all
    puts "      Data for " + model_class.class_name + " purged."
  end
  
  def load_fixture(model_class)
    directory = File.join(File.dirname(__FILE__), "../../db/migrate/dev_data")
    Fixtures.create_fixtures(directory, model_class.class_name.tableize)
    puts "      Fixtures for " + model_class.class_name + " loaded."
  end
  
  def list_fixtures
    fixture_dir = "db/migrate/dev_data"
    puts "in #{fixture_dir}:"
    FileList["#{fixture_dir}/*.yml"].each do |f|
      fixture_name = File.basename(f, ".yml")
      puts fixture_name + " "*(35-fixture_name.size) + "rake fixtures:load MODEL=" + fixture_name.classify
    end
  end
  
  desc "Reload default system settings"
  task :reload_system_settings => :environment do
    require 'active_record/fixtures'
    require 'finder_helper'
    SystemSetting.delete_all ["scope_id = ?", 1]
    load_fixture(SystemSetting)
  end
  
  desc "Reload default authorization_levels"
  task :reload_authorization_levels => :environment do
    require 'active_record/fixtures'
    require 'finder_helper'
    AuthorizationLevel.delete_all ["id < ?", 100]
    load_fixture(AuthorizationLevel)
  end

end
