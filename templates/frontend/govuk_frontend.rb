def initialize_govuk_frontend_assets
  say "    - Adding GOV.UK Frontend assets"
  run "yarn --silent add govuk-frontend"

  return if file_contains?("config/initializers/assets.rb", "govuk-frontend")

  assets_config = <<-RUBY
# Additional assets for govuk-frontend
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets')
  
  RUBY

  insert_into_file(
    'config/initializers/assets.rb',
    assets_config,
  )

  remove_file 'public/icon.png'
  remove_file 'public/icon.svg'
end

def create_application_scss
  say "    - Setting up SASS stylesheets"
  remove_file("app/assets/stylesheets/application.css")

  remove_file('app/assets/stylesheets/application.sass.scss', verbose: false)
  template('template_files/app/assets/stylesheets/application.sass.scss', 'app/assets/stylesheets/application.sass.scss')
end

def create_application_js
  say "    - Setting up JavaScript"
  remove_file('app/javascript/application.js', verbose: false)
  template('template_files/app/javascript/application.js', 'app/javascript/application.js')
end

def create_application_html_erb
  say "    - Setting up application layout"
  remove_file('app/views/layouts/application.html.erb', verbose: false)
  template('template_files/app/views/layouts/application.html.erb', 'app/views/layouts/application.html.erb')
  remove_dir("app/views/pwa", verbose: false)
end

def add_en_yml
  say "    - Setting up locales"
  return unless file_contains?('config/locales/en.yml', 'Hello world')
  remove_file('config/locales/en.yml', verbose: false)
  template('template_files/config/locales/en.yml', 'config/locales/en.yml')
end

def apply_template!
  initialize_govuk_frontend_assets
  create_application_scss
  create_application_js
  create_application_html_erb
  add_en_yml
end

apply_template!