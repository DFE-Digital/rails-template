gem_group :development, :test do
  gem "rspec"
  gem "rspec-rails"
  gem "capybara"
  gem "factory_bot_rails"
  gem "shoulda-matchers"
end unless file_contains?("Gemfile", 'rspec-rails')

run "bundle install --quiet"

generate("rspec:install") unless file_exists?(".rspec")

run "bundle binstubs rspec-core"

template('template_files/spec/support/capybara.rb', 'spec/support/capybara.rb')
template('template_files/spec/support/factory_bot.rb', 'spec/support/factory_bot.rb')
template('template_files/spec/support/shoulda_matchers.rb', 'spec/support/shoulda_matchers.rb')
template('template_files/spec/support/time_helper.rb', 'spec/support/time_helper.rb')
template('template_files/spec/requests/smoke_test_spec.rb', 'spec/requests/smoke_test_spec.rb')

uncomment_lines 'spec/rails_helper.rb', /Rails.root.glob/
uncomment_lines 'spec/rails_helper.rb', /config.infer_spec_type_from_file_location!/

default_fixtures_config = <<-RUBY
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]
RUBY

removed_fixtures_config = <<-RUBY
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_paths = [
  #   Rails.root.join('spec/fixtures')
  # ]
RUBY

gsub_file("spec/rails_helper.rb", default_fixtures_config, removed_fixtures_config)

ci_steps = <<-RUBY
step "Tests: Rails", "bin/rspec --format documentation"

RUBY

insert_into_file "config/ci.rb", ci_steps, before: "# Optional:"