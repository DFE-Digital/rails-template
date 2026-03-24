def initialize_govuk_frontend_assets
  run "yarn --silent add govuk-frontend@5.11.1"

  return if file_contains?("config/application.rb", "govuk-frontend")

  insert_into_file(
    'config/application.rb',
    "\nconfig.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets')\n".indent(4),
    before: "  end\nend"
  )

  remove_file("config/initializers/assets.rb")
end

def create_application_scss
  remove_file("app/assets/stylesheets/application.css")

  remove_file('app/assets/stylesheets/application.sass.scss', verbose: false)
  template('app/assets/stylesheets/application.sass.scss')
end

def create_application_js
  remove_file('app/javascript/application.js', verbose: false)
  template('app/javascript/application.js')
end

def create_application_html_erb
  remove_file('app/views/layouts/application.html.erb', verbose: false)
  template('app/views/layouts/application.html.erb')
end

def add_en_yml
  return unless file_contains?('config/locales/en.yml', 'Hello world')
  remove_file('config/locales/en.yml', verbose: false)
  template('config/locales/en.yml')
end

def apply_template!
  initialize_govuk_frontend_assets
  create_application_scss
  create_application_js
  create_application_html_erb
  add_en_yml
end

apply_template!