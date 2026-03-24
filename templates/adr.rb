gem_group :development do
  gem 'rladr'
end

run "bundle install --quiet"

run "bundle exec rladr init adr"

append_to_file(
  'README.md',
  <<~MD
    ## How the application works

    We keep track of architecture decisions in [Architecture Decision Records
    (ADRs)](/adr/).

    We use `rladr` to generate the boilerplate for new records:

    ```bash
    bundle exec rladr new title
    ```
  MD
)

template 'adr/00001-record-architecture-decisions.md', force: true

gsub_file(
  'adr/00001-record-architecture-decisions.md',
  /2022-05-10/,
  Time.new.strftime('%Y-%m-%d')
)
