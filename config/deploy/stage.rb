set :deploy_host, 'kurma-earthworks-stage'
set :deploy_user, 'geostaff'
set :home_directory, "/opt/app/#{fetch(:deploy_user)}"
set :deploy_to, "#{fetch(:home_directory)}/#{fetch(:application)}"

server "#{fetch(:deploy_host)}.stanford.edu", user: fetch(:deploy_user), roles: %w{web db app}

Capistrano::OneTimeKey.generate_one_time_key!

set :bundle_without, %w{sqlite production test}.join(' ')

set :rails_env, "stage"