fail("Rails 7.0.0 or greater is required") if Rails.version <= "7"

def apply_template!
  add_template_repository_to_source_path

  install_gems
  initialize_package_json

  create_bin_bundle
  create_application_scss
  create_application_js
  create_application_html_erb

  initialize_rspec
  initialize_formbuilder
  initialize_govuk_frontend_assets

  add_pages_controller
  add_en_yml
  add_docker

  setup_yarn

  setup_adrs
  setup_error_pages
  setup_asdf
  setup_linting
  setup_solargraph # Needs to come after linting

  after_bundle do
    initialize_git
  end
end

# Taken from https://github.com/mattbrictson/rails-template/blob/215a87d00ff2b2a656be3ebd277e7f71607f5d49/template.rb#L99
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/DFE-Digital/rails-template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def file_exists?(file)
  File.exist?(file)
end

def file_contains?(file, contains)
  return false unless file_exists?(file)

  File.foreach(file).any? { |line| line.include?(contains) }
end

def install_gems
  gem "govuk-components" unless file_contains?("Gemfile", "govuk-components")
  gem "govuk_design_system_formbuilder" unless
    file_contains?("Gemfile", "govuk_design_system_formbuilder")

  gem_group :test do
    gem "rspec"
    gem "rspec-rails"
  end unless file_contains?("Gemfile", 'rspec-rails')

  run "bundle --quiet"
end

def create_application_scss
  remove_file("app/assets/stylesheets/application.css")

  template('app/assets/stylesheets/application.sass.scss')
end

def create_application_js
  template('app/javascript/application.js')
end

def create_application_html_erb
  template('app/views/layouts/application.html.erb')
end

def add_pages_controller
  return if file_exists?("app/controllers/pages_controller.rb")

  generate("controller", "pages", "home", "--skip-routes")
  route("root to: 'pages#home'") unless file_contains?("config/routes.rb", "root to:")

  template('app/views/pages/home.html.erb', force: true)
end

def initialize_package_json
  return if file_contains?('package.json', 'esbuild')
  run "rails css:install:sass"
  run "rails javascript:install:esbuild"

  gsub_file(
    'package.json',
    /--load-path=node_modules/,
    '--load-path=node_modules --quiet-deps'
  )
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

  template('config/initializers/govuk_formbuilder.rb')
end

def initialize_govuk_frontend_assets
  return if file_contains?("config/application.rb", "govuk-frontend")

  insert_into_file(
    'config/application.rb',
    "\nconfig.assets.paths << Rails.root.join('node_modules/govuk-frontend/govuk/assets')\n".indent(4),
    before: "  end\nend"
  )

  remove_file("config/initializers/assets.rb")
end

def setup_yarn
  run "yarn --silent add govuk-frontend@4.0.1"
end

def initialize_git
  template('gitignore', '.gitignore')

  git(init: "--initial-branch=main")
  git(add: ".")
  git(commit: <<~COMMIT)
    -m "Initial commit

    Built using the Department for Education's Rails template"
  COMMIT
end

def create_bin_bundle
  template('bin/bundle')

  chmod "bin/bundle", "+x"
end

def setup_adrs
  return say('ADRs already setup, skipping') if file_contains?('Gemfile', 'rladr')
  say("\n=== Architecture Decision Records (ADRs) ===")
  return unless yes?('Add `rladr` for Architecture Decision Record (ADR) support? y/N')

  apply 'adr/template.rb'
end

def setup_asdf
  return say('asdf already setup, skipping') if file_exists?('.tool-versions')
  say("\n=== `asdf-vm` https://asdf-vm.com/ ===")
  return unless yes?('Add `asdf` for Ruby/Node/Yarn versioning support? y/N')

  apply 'templates/asdf.rb'
end

def add_en_yml
  template('config/locales/en.yml') if file_contains?('config/locales/en.yml', 'Hello world')
end

def add_docker
  template('Dockerfile')
  template('dockerignore', '.dockerignore')
end

def setup_error_pages
  return say('Error pages already setup, skipping') if file_exists?('app/controllers/errors_controller.rb')
  say("\n=== GOV.UK styled error pages ===")
  return unless yes?('Add GOV.UK styled error pages? y/N')

  apply 'templates/errors.rb'
end

def setup_linting
  return say('linting already setup, skipping') if file_exists?('.rubocop.yml')
  say("\n=== Rubocop and prettier ===")
  return unless yes?('Add govuk-rubocop and Prettier for linting/formatting? y/N')

  apply 'templates/linting.rb'
end

def setup_solargraph
  return say('solargraph already setup, skipping') if file_exists?('.solargraph.yml')
  say("\n=== solargraph https://solargraph.org/ ===")
  return unless yes?('Add solargraph for Ruby intellisense support? y/N')

  apply 'templates/solargraph.rb'
end

apply_template!
