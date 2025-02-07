# Rails 7 application template

[DFE-Digital/rails-template](https://guides.rubyonrails.org/rails_application_templates.html)
is a [Rails application
template](https://guides.rubyonrails.org/rails_application_templates.html) that
makes starting a new GOV.UK Rails project fast and fun.

## What's included

- [GOV.UK Frontend 4.4.1](https://github.com/alphagov/govuk-frontend)
- [GOV.UK Components](https://govuk-components.netlify.app/)
- [GOV.UK Form Builder](https://govuk-form-builder.netlify.app/)
- [RSpec](https://rspec.info/)
- Production/PaaS/Terraform ready Dockerfile
- (optional) [Architecture decision record
  support](https://github.com/andrewaguiar/rladr)
- (optional) GOV.UK styled error pages
- (optional) [asdf](https://asdf-vm.com/) versioning
- (optional) [solargraph](https://solargraph.org/) with bundled gem support
- (optional) Linting with
  [rubocop-govuk](https://github.com/alphagov/rubocop-govuk), formatting with
  [prettier/plugin-ruby](https://github.com/prettier/plugin-ruby)

### What's improved from the [old boilerplate](https://github.com/DFE-Digital/govuk-rails-boilerplate)

- :new: Ruby 3, Rails 7, and the template does not require us to manually merge
  dependabot PRs or to keep Ruby/Rails up to date; that's handled by `rails new`!
- :new: [rails/propshaft](https://github.com/rails/propshaft) asset pipeline
- :new: [cssbundling](https://github.com/rails/cssbundling-rails) /
  [jsbundling](https://github.com/rails/jsbundling-rails) with
  [dart-sass](https://sass-lang.com/dart-sass) and
  [esbuild](https://esbuild.github.io/), no more Webpack!
- :new: [Importing improvements from the
  template](#importing-improvements-from-the-template)

## Requirements

- Ruby 3.2.2
- Rails 7.0.x
- [Foreman](https://github.com/ddollar/foreman)

### Tools optionally installed by asdf

The following tools will be installed by `asdf` if it is enabled during the
setup process (see: [How to setup a new project](#how-to-setup-a-new-project)).

- [NodeJS 18.x](https://nodejs.org/en/) (installed using `asdf`)
- [Yarn 1.22.x](https://yarnpkg.com/)
- Postgres 13.x

If `asdf` is not used, ensure these are available and in your path. You can check this with: 

``` sh
$ ruby --version
ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-linux]

$ rails --version
Rails 7.0.4

$ node --version
v18.1.0

$ yarn --version
1.22.19

$ foreman --version
0.87.2

$ pg_config --version
PostgreSQL 13.5
```

## How to setup a new project

To create a new application called `apply-for-a-juggling-licence`:

```sh
rails new \
  --database=postgresql \
  --skip-bundle \
  --skip-git \
  --skip-jbuilder \
  --skip-hotwire \
  --skip-action-mailbox \
  --skip-action-mailer \
  --skip-action-text \
  --asset-pipeline=propshaft \
  --javascript=esbuild \
  --css=sass \
  -m https://raw.githubusercontent.com/DFE-Digital/rails-template/main/template.rb \
  apply-for-a-juggling-licence
```

The installer will ask you to confirm `y/N` if you want any optional features.

Once the project is set up, tidy up the `README`, it should already contain
some references to helpful things like ADRs/linting if you opted into them.

### Working with the project

```bash
# Make sure Postgres is running
cd apply-for-a-juggling-licence
asdf install           # Install Ruby/Node/other tools, see README
bin/setup              # Install gems, create databases, remove old logs
bin/dev                # Run the application in development mode using foreman
open http://localhost:3000

# Production
bin/rails db:create RAILS_ENV=production # Prepare database
docker build .                           # Build docker container
docker run --net=host \
  -e RAILS_ENV=production \
  -e RAILS_SERVE_STATIC_FILES=true \
  -e SECRET_KEY_BASE=local \
  <DOCKER_IMAGE_ID_FROM_BUILD_COMMAND>
open http://localhost:3000
```

### Importing improvements from the template

We might make changes to the template to improve how things work, or add new
features. We've tried to make it easy to benefit from these changes.

To apply the template to an existing project, run this from inside your
project:

```sh
bin/rails app:template LOCATION=https://raw.githubusercontent.com/DFE-Digital/rails-template/main/template.rb
```

The script will ask to overwrite diverging files; press the `d` key to see the
diffs for each file, and choose accordingly. You might have to make some
changes yourself if you've overriden certain files, like the layout.

### Support

The DfE Rails template is a community resource. It is supported by
@DfE-Digital. If you run into any problems using it or have ideas for new
features you can [raise an issue](https://github.com/DFE-Digital/rails-template/issues)
or [ask questions on Slack](https://ukgovernmentdigital.slack.com/archives/CR51BN3HP).
