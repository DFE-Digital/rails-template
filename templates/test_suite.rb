gem_group :test, :development do
  gem "rspec"
  gem "rspec-rails"
end unless file_contains?("Gemfile", 'rspec-rails')

run "bundle --quiet"

generate("rspec:install") unless file_exists?(".rspec")