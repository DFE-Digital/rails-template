if Rails.env.development? || Rails.env.production?
  Rails.application.configure do
    config.log_tags = [:request_id] # Prepend all log lines with the following tags
  end

  SemanticLogger.add_appender(io: $stdout, level: Rails.application.config.log_level, formatter: Rails.application.config.log_format)
  Rails.application.config.logger.info("Application logging to STDOUT")
end
