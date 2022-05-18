inject_into_file(
  "Gemfile",
  "gem 'rladr'\n".indent(2),
  after: "group :development do\n"
)

run "bin/bundle --quiet"

run "bin/bundle exec rladr init adr"

append_to_file(
  'README.md',
  <<~MD
    ## How the application works

    We keep track of architecture decisions in [Architecture Decision Records
    (ADRs)](/adr/).

    We use `rladr` to generate the boilerplate for new records:

    ```bash
    bin/bundle exec rladr new title
    ```
  MD
)

template 'adr/00001-record-architecture-decisions.md', force: true

gsub_file(
  'adr/00001-record-architecture-decisions.md',
  /2022-05-10/,
  Time.new.strftime('%Y-%m-%d')
)
