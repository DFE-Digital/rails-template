fail("Rails 7.0.0 or greater is required") if Rails.version <= "7"

def file_exists?(file)
  File.exist?(file)
end

def file_contains?(file, contains)
  return false unless file_exists?(file)

  File.foreach(file).any? { |line| line.include?(contains) }
end

def read_template(path)
  File.read(File.join(__dir__, 'tmpl', path))
end

def install_gems
  gem "govuk-components" unless file_contains?("Gemfile", "govuk-components")
  gem "govuk_design_system_formbuilder" unless
    file_contains?("Gemfile", "govuk_design_system_formbuilder")

  gem_group :test do
    gem "rspec"
    gem "rspec-rails"
  end unless file_contains?("Gemfile", 'rspec-rails')

  run "bundle install"
end

def create_procfile
  file("Procfile.dev", read_template('Procfile.dev'))
end

def create_bin_dev
  file("bin/dev", read_template('bin_dev.sh'))

  chmod "bin/dev", "+x"
end

def create_manifest_js
  file("app/assets/config/manifest.js", read_template('manifest.js'))
end

def create_package_json
  file("package.json", read_template('package.json'))
end

def create_application_scss
  remove_file("app/assets/stylesheets/application.css")

  file("app/assets/stylesheets/application.scss", read_template('application.scss'))
end

def create_application_js
  file("app/javascript/application.js", read_template('application.js'))
end

def create_application_html_erb
  file("app/views/layouts/application.html.erb", read_template('application.html.erb'))
end

def add_pages_controller
  return if file_exists?("app/controllers/pages_controller.rb")

  generate("controller", "pages", "home", "--skip-routes")
  route("root to: 'pages#home'") unless file_contains?("config/routes.rb", "root to:")

  file("app/views/pages/home.html.erb", read_template('home.html.erb'), force: true)
end

def initialize_rspec
  generate("rspec:install") unless file_exists?(".rspec")
end

def initialize_formbuilder
  return if file_contains?("config/initializers/govuk_formbuilder.rb", "GOVUKDesignSystemFormBuilder")

  inject_into_file(
    "app/controllers/application_controller.rb",
    "default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)\n".indent(2),
    after: "class ApplicationController < ActionController::Base\n"
  )

  file("config/initializers/govuk_formbuilder.rb", read_template('govuk_formbuilder.rb'))
end

def setup_yarn
  empty_directory "app/assets/builds"

  run "yarn"
end

def initialize_git
  append_to_file(".gitignore", read_template('.gitignore'))

  git(:init)
  git(add: ".")
  git(commit: <<~COMMIT)
    -m "Initial commit

    Built using the Department for Education's Rails template"
  COMMIT
end

def create_bin_bundle
  file("bin/bundle", read_template('bin_bundle.rb'))

  chmod "bin/bundle", "+x"
end

install_gems

create_procfile
create_bin_dev
create_bin_bundle
create_manifest_js
create_package_json
create_application_scss
create_application_js
create_application_html_erb

initialize_rspec
initialize_formbuilder

add_pages_controller

setup_yarn

after_bundle do
  initialize_git
end
