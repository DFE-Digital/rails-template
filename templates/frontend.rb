def initialize_formbuilder
  return if file_contains?("config/initializers/govuk_formbuilder.rb", "GOVUKDesignSystemFormBuilder")

  inject_into_file(
    "app/controllers/application_controller.rb",
    "default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)\n".indent(2),
    after: "class ApplicationController < ActionController::Base\n"
  )

  template('template_files/config/initializers/govuk_formbuilder.rb', 'config/initializers/govuk_formbuilder.rb')
end

def setup_govuk_frontend
  apply "templates/frontend/govuk_frontend.rb"
end

def setup_govuk_components
  gem "govuk-components" unless file_contains?("Gemfile", "govuk-components")
end

def setup_govuk_formbuilder
  gem "govuk_design_system_formbuilder" unless
    file_contains?("Gemfile", "govuk_design_system_formbuilder")

  initialize_formbuilder
end

def add_pages_controller
  return if file_exists?("app/controllers/pages_controller.rb")

  generate("controller", "pages", "home", "--skip-routes")
  route("root to: 'pages#home'") unless file_contains?("config/routes.rb", "root to:")

  template('template_files/app/views/pages/home.html.erb', 'app/views/pages/home.html.erb', force: true)
end

def setup_error_pages
  say("\n=== GOV.UK styled error pages ===")

  apply 'templates/errors.rb'
end

def add_quite_deps_for_sass
  return if file_contains?('package.json', '--quiet-deps')

  gsub_file(
    'package.json',
    /--load-path=node_modules/,
    '--load-path=node_modules --quiet-deps'
  )
end

def apply_template!
  setup_govuk_frontend
  setup_govuk_components
  setup_govuk_formbuilder

  add_pages_controller
  setup_error_pages

  add_quite_deps_for_sass
end

apply_template!