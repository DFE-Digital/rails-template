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
  file(
    "Procfile.dev",
    <<~PROCFILE
      web: bin/rails server -p 3000
      js: yarn build:js --watch
      css: yarn build:css --watch
    PROCFILE
  )
end

def create_bin_dev
  file(
    "bin/dev",
    <<~SH
      #!/usr/bin/env bash

      foreman start -f Procfile.dev
    SH
  )

  run "chmod +x bin/dev"
end

def create_manifest_js
  file("app/assets/config/manifest.js") do
    <<~JS
      //= link_tree ../builds/images
      //= link_tree ../builds/
    JS
  end
end

def create_package_json
  file(
    "package.json",
    <<~JSON
      {
        "name": "app",
        "private": "true",
        "dependencies": {
          "@hotwired/stimulus": "^3.0.1",
          "@hotwired/turbo-rails": "^7.1.1",
          "govuk-frontend": "^4.0.1",
          "esbuild": "^0.14.23",
          "sass": "^1.49.8"
        },
        "scripts": {
          "build:css": "sass --embed-sources --quiet-deps --load-path=node_modules ./app/assets/stylesheets/application.scss ./app/assets/builds/application.css",
          "build:js": "esbuild app/javascript/*.* --bundle --outdir=app/assets/builds",
          "preinstall": "mkdir -p app/assets/builds/{fonts,images}",
          "postinstall": "cp -R node_modules/govuk-frontend/govuk/assets/fonts/. app/assets/builds/fonts && cp -R node_modules/govuk-frontend/govuk/assets/images/. app/assets/builds/images"
        }
      }
    JSON
  )
end

def create_application_scss
  remove_file("app/assets/stylesheets/application.css")

  file("app/assets/stylesheets/application.scss") do
    <<~SCSS
      @use "govuk-frontend/govuk/all";
    SCSS
  end
end

def create_application_js
  file("app/javascript/application.js") do
    <<~JAVASCRIPT
      import "@hotwired/turbo-rails";
      // import "./controllers";

      import { initAll } from "govuk-frontend";

      initAll();
    JAVASCRIPT
  end
end

def create_application_html_erb
  file("app/views/layouts/application.html.erb") do
    <<~ERB
      <!DOCTYPE html>
      <html lang="en" class="govuk-template">
        <head>
          <title>GOV.UK Frontend on Rails</title>

          <%= csrf_meta_tags %>
          <%= csp_meta_tag %>

          <%= tag :meta, name: 'viewport', content: 'width=device-width, initial-scale=1' %>
          <%= tag :meta, property: 'og:image', content: asset_path('images/govuk-opengraph-image.png') %>
          <%= tag :meta, name: 'theme-color', content: '#0b0c0c' %>
          <%= favicon_link_tag asset_path('images/favicon.ico') %>
          <%= favicon_link_tag asset_path('images/govuk-mask-icon.svg'), rel: 'mask-icon', type: 'image/svg', color: "#0b0c0c" %>
          <%= favicon_link_tag asset_path('images/govuk-apple-touch-icon.png'), rel: 'apple-touch-icon', type: 'image/png' %>
          <%= favicon_link_tag asset_path('images/govuk-apple-touch-icon-152x152.png'), rel: 'apple-touch-icon', type: 'image/png', size: '152x152' %>
          <%= favicon_link_tag asset_path('images/govuk-apple-touch-icon-167x167.png'), rel: 'apple-touch-icon', type: 'image/png', size: '167x167' %>
          <%= favicon_link_tag asset_path('images/govuk-apple-touch-icon-180x180.png'), rel: 'apple-touch-icon', type: 'image/png', size: '180x180' %>

          <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
          <%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %>
        </head>

        <body class="govuk-template__body">
          <script>
            document.body.className = ((document.body.className) ? document.body.className + ' js-enabled' : 'js-enabled');
          </script>

          <%= govuk_skip_link %>

          <%= govuk_header(service_name: "GOV.UK Rails Boilerplate") do |header| %>
            <%= header.navigation_item(text: "Navigation item 1", href: "#", active: true) %>
            <%= header.navigation_item(text: "Navigation item 2", href: "#") %>
            <%= header.navigation_item(text: "Navigation item 3", href: "#") %>
          <% end %>

          <div class="govuk-width-container">
            <main class="govuk-main-wrapper" id="main-content" role="main">
              <%= yield %>
            </main>
          </div>

          <%= govuk_footer %>
        </body>
      </html>
    ERB
  end
end

def add_pages_controller
  return if file_exists?("app/controllers/pages_controller.rb")

  generate("controller", "pages", "home", "--skip-routes")
  route("root to: 'pages#home'") unless file_contains?("config/routes.rb", "root to:")

  file("app/views/pages/home.html.erb", force: true) do
    <<~ERB
      <div class="govuk-grid-row">
        <div class="govuk-grid-column-two-thirds">
          <h1 class="govuk-heading-xl">It works! 🎉</h1>

          <p class="govuk-body">
            Your application is ready - so long as this page rendered without any errors you're good to go.
          </p>

          <%= govuk_summary_list(
            rows: [
              { key: { text: "Rails version" }, value: { text:  Rails.version } },
              { key: { text: "Ruby version" }, value: { text:  RUBY_VERSION } },
              { key: {
                text: "GOV.UK Frontend" },
                value: {
                  text: JSON
                    .parse(File.read(Rails.root.join("package.json")))
                    .dig("dependencies", "govuk-frontend")
                    .tr("^", "")
                }
              }
            ]
          ) %>
        </div>
      </div>
    ERB
  end
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

  file("config/initializers/govuk_formbuilder.rb") do
    <<~RUBY
      GOVUKDesignSystemFormBuilder.configure do |config|
        # for more info see:
        #
        # https://www.rubydoc.info/gems/govuk_design_system_formbuilder/GOVUKDesignSystemFormBuilder

        # config.brand: 'govuk'
        #
        # config.default_legend_size: 'm'
        # config.default_legend_tag: nil
        # config.default_caption_size: 'm'
        # config.default_submit_button_text: 'Continue'
        # config.default_radio_divider_text: 'or'
        # config.default_check_box_divider_text: 'or'
        # config.default_error_summary_title: 'There is a problem'
        # config.default_error_summary_presenter: Presenters::ErrorSummaryPresenter
        # config.default_error_summary_error_order_method: nil
        # config.default_error_summary_turbo_prefix: 'turbo'
        # config.default_collection_check_boxes_include_hidden: true
        # config.default_collection_radio_buttons_include_hidden: true
        # config.default_submit_validate: false
        #
        # config.localisation_schema_fallback: %i(helpers __context__)
        # config.localisation_schema_label: nil
        # config.localisation_schema_hint: nil
        # config.localisation_schema_legend: nil
        # config.localisation_schema_caption: nil
        #
        # config.enable_logger: true
        # config.trust_error_messages: false
      end
    RUBY
  end
end

def setup_yarn
  empty_directory "app/assets/builds"

  run "yarn"
end

def initialize_git
  append_to_file(
    ".gitignore",
    <<~GITIGNORE
      # Frontend artifacts and libs
      app/assets/builds/*
      node_modules

      # Platform/IDE-specific settings
      .DS_Store
      .idea
      .vscode

      # Local env settings
      .env
      .envrc
      .env.local
    GITIGNORE
  )

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
