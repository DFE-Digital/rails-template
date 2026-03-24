def initialize_formbuilder
  return if file_contains?("config/initializers/govuk_formbuilder.rb", "GOVUKDesignSystemFormBuilder")

  inject_into_file(
    "app/controllers/application_controller.rb",
    "default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)\n".indent(2),
    after: "class ApplicationController < ActionController::Base\n"
  )

  template('config/initializers/govuk_formbuilder.rb')
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

def apply_template!
  setup_govuk_frontend
  setup_govuk_components
  setup_govuk_formbuilder
end

apply_template!