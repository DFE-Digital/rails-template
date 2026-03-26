unless file_exists?("config/initializers/semantic_logger.rb")
  template("template_files/config/initializers/semantic_logger.rb", "config/initializers/semantic_logger.rb")
end

gem_group :development, :production do
  gem "amazing_print" unless file_contains?("Gemfile", "amazing_print")
  gem "rails_semantic_logger"
end unless file_contains?("Gemfile", 'rails_semantic_logger')

run "bundle install --quiet"

development_config = <<-RUBY
  # Semantic logging for integration with Kibana
  config.log_level = :info                        # Or :debug
  config.log_format = :color                      # Console colorised non-json output
  config.semantic_logger.backtrace_level = :debug # Show file and line number (expensive: not for production)
  
RUBY

environment development_config, env: :development

production_config = <<-RUBY
  # Semantic logging for integration with Kibana
  config.log_level = :info                                # Or :warn, or :error
  config.log_format = :json                               # For parsing in Logit
  config.rails_semantic_logger.add_file_appender = false  # Don't log to file
  config.active_record.logger = nil                       # Don't log SQL
  
RUBY

environment production_config, env: :production
