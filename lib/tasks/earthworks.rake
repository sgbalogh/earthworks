# sitemap:create to generate sitemaps, 
# sitemap:refresh to generate sitemaps and ping search engines, 
# sitemap:clean to remove sitemap files
require 'sitemap_generator/tasks' 

require 'jettywrapper'
namespace :earthworks do
  desc 'Install EarthWorks'
  task install: [:environment] do
    Rake::Task['db:migrate'].invoke
    Rake::Task['earthworks:download_and_unzip_jetty'].invoke
    Rake::Task['earthworks:copy_solr_configs'].invoke
    Jettywrapper.wrap(Jettywrapper.load_config) do
      Rake::Task['geoblacklight:solr:seed'].invoke
    end
  end
  desc 'Index test fixtures'
  task :fixtures do
    Rake::Task['geoblacklight:solr:seed'].invoke
  end
  desc 'Download and unzip jetty'
  task :download_and_unzip_jetty do
    unless File.exist?("#{Rails.root}/jetty")
      puts 'Downloading jetty'
      Rake::Task['jetty:download'].invoke
      puts 'Unzipping jetty'
      Rake::Task['jetty:unzip'].invoke
    end
  end
  desc 'Copy solr configs'
  task :copy_solr_configs do
    %w{schema solrconfig}.each do |file|
      cp "#{Rails.root}/config/solr_configs/#{file}.xml", "#{Rails.root}/jetty/solr/blacklight-core/conf/"
    end
  end
  desc 'Load GeoMonitor availability scores in geomonitor_datafile into Solr index at solr_url'
  task :update_availability, :solr_url, :geomonitor_datafile do |t, args|
      system "ruby #{Rails.root}/tools/geomonitor/update.rb #{args.solr_url} #{args.geomonitor_datafile}"
  end
  namespace :spec do
    begin
      require 'rspec/core/rake_task'
      desc 'spec task that runs only data-integration tests (run locally against production data)'
      RSpec::Core::RakeTask.new('data-integration') do |t|
        t.rspec_opts = '--tag data-integration'
      end
      desc 'spec task that ignores data-integration tests (run during local development/travis on local data)'
      RSpec::Core::RakeTask.new('without-data-integration') do |t|
        t.rspec_opts =  '--tag ~data-integration'
      end
      task 'spec:all' => 'test:prepare'
    rescue LoadError => e
      desc 'rspec not installed'
      task 'data-integration' do
        abort 'rspec not installed'
      end
      desc 'rspec not installed'
      task 'without-data-integration' do
        abort 'rspec not installed'
      end
    end
  end
end
