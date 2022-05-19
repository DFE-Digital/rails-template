template '.rubocop.yml'
template '.prettierignore'
template 'bin/lint'

inject_into_file(
  "Gemfile",
  'gem "prettier_print", require: false' \
  'gem "rubocop-govuk", require: false' \
  'gem "syntax_tree", require: false' \
  'gem "syntax_tree-haml", require: false' \
  'gem "syntax_tree-rbs", require: false' \.indent(2),
  after: "group :development do\n"
)

run "bin/bundle --quiet"

run "yarn add --dev prettier @prettier/plugin-ruby"

append_to_file(
  'README.md',
  <<~MD
    ### Linting

    To run the linters:

    ```bash
    bin/lint
    ```
  MD
)
