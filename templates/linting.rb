say "  - Installing rubocop and linters"

template 'template_files/.rubocop.yml', '.rubocop.yml', force: true

gem_group :development, :test do
  gem "rubocop-govuk", require: false
end

run "bundle install --quiet"

append_to_file(
  'README.md',
  <<~MD
    ### Linting

    To run the linters:

    ```bash
    bin/rubocop
    ```

    Autofix linting errors:

    ```bash
    bin/rubocop --autocorrect-all
    ```
  MD
)
