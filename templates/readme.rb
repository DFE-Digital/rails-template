#!/usr/bin/env ruby

append_to_file(
  'README.md',
  <<~MD

    ## Setup

    ### Prerequisites

    This project depends on:

      - [Ruby](https://www.ruby-lang.org/)
      - [Ruby on Rails](https://rubyonrails.org/)
      - [NodeJS](https://nodejs.org/)
      - [Yarn](https://yarnpkg.com/)
      - [Postgres](https://www.postgresql.org/)

  MD
)
