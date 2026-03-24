def setup_govuk_frontend

end

def setup_govuk_components
  gem "govuk-components" unless file_contains?("Gemfile", "govuk-components")
end

def setup_govuk_formbuilder
  gem "govuk_design_system_formbuilder" unless
    file_contains?("Gemfile", "govuk_design_system_formbuilder")
end

def apply_template!
  setup_govuk_frontend
  setup_govuk_components
  setup_govuk_formbuilder
end

apply_template!