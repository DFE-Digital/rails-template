gem 'dfe-analytics', github: 'DFE-Digital/dfe-analytics', tag: 'v1.15.8'

bundle_command("install --quiet")

run "rails generate dfe:analytics:install"

airbyte_config = <<-RUBY
  # Set a config file for Airbyte
  config.airbyte_stream_config_path = 'config/analytics_airbyte_stream_config.json'
  
RUBY
# FIXME: Uncomment this whent he version is updated
# insert_into_file("config/initializers/dfe_analytics.rb", airbyte_config, after: "DfE::Analytics.configure do |config|\n" )

azure_federated_auth_config = <<-RUBY
  # FIXME: Review this setting to ensure it's appropriate for your application
  # Use Azure Federated Auth [see docs](https://github.com/DFE-Digital/dfe-analytics?tab=readme-ov-file#31-workload-identity-federation) 
  config.azure_federated_auth = true
  
RUBY
gsub_file("config/initializers/dfe_analytics.rb", " # config.azure_federated_auth = false", azure_federated_auth_config)

log_only_config = <<-RUBY
  # FIXME: Review this setting to ensure it's appropriate for your application
  config.log_only = Rails.env.local? 

RUBY
gsub_file("config/initializers/dfe_analytics.rb", " # config.log_only = true", log_only_config)

async_config = <<-RUBY
  # FIXME: Review this setting to ensure it's appropriate for your application
  config.async = !Rails.env.local? 
RUBY
gsub_file("config/initializers/dfe_analytics.rb", " # config.async = true", async_config)

queue_config = <<-RUBY
  config.queue = :dfe_analytics
RUBY
gsub_file("config/initializers/dfe_analytics.rb", " # config.queue = :default", queue_config)

inject_into_file(
  "app/controllers/application_controller.rb",
  "include DfE::Analytics::Requests\n".indent(2),
  after: "class ApplicationController < ActionController::Base\n"
)