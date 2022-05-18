template 'solargraph.yml', '.solargraph.yml'

inject_into_file(
  "Gemfile",
  "gem 'annotate', require: false\n" \
  "gem 'solargraph', require: false\n" \
  "gem 'solargraph-rails', require: false\n".indent(2),
  after: "group :development do\n"
)

run "bin/bundle --quiet"

run "bin/rails generate annotate:install"

append_to_file(
  'README.md',
  <<~MD
    ### Intellisense

    [solargraph](https://github.com/castwide/solargraph) is bundled as part of the
    development dependencies. You need to [set it up for your
    editor](https://github.com/castwide/solargraph#using-solargraph), and then run
    this command to index your local bundle (re-run if/when we install new
    dependencies and you want completion):

    ```sh
    bin/bundle exec yard gems
    ```

    You'll also need to configure your editor's `solargraph` plugin to
    `useBundler`:

    ```diff
    +  "solargraph.useBundler": true,
    ```
  MD
)
