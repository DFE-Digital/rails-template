# Rails 8 application template

[DFE-Digital/rails-template](https://guides.rubyonrails.org/rails_application_templates.html) is
a [Rails application template](https://guides.rubyonrails.org/rails_application_templates.html) that makes starting a
new GOV.UK Rails project fast and fun.

## What's included

- [GOV.UK Frontend 5.8.0](https://github.com/alphagov/govuk-frontend)
- [GOV.UK Components](https://govuk-components.netlify.app/)
- [GOV.UK Form Builder](https://govuk-form-builder.netlify.app/)
- [RSpec](https://rspec.info/) with support files
- Production-ready Docker setup with reproducible builds
- [Architecture decision records](https://github.com/andrewaguiar/rladr)
- GOV.UK styled error pages
- [Solargraph](https://solargraph.org/) for IDE support
- Linting with [rubocop-govuk](https://github.com/alphagov/rubocop-govuk) and [prettier/plugin-ruby](https://github.com/prettier/plugin-ruby)
- Semantic logging configured for development and production

## Requirements

- Ruby 4.0.2 (or any supported Rails 8 version)
- Node 24.14.0 (or any recent LTS version)
- Postgres (running locally or via Docker)
- [asdf](https://asdf-vm.com/) with Ruby and NodeJS plugins

The template will automatically use whatever Ruby and Node versions you have installed. The versions above are just recommendations. The Dockerfile and package.json will be configured with your actual versions.

**Note on Yarn**: if you have the asdf yarn plugin installed, remove it first. This is only needed for Yarn v1. We're now on Yarn v4, so you can remove it. Check with `which yarn` — if it returns an asdf path, remove the plugin, reshim, and restart your terminal.

## Getting started

### 1. Create your project directory

```bash
mkdir apply-for-a-juggling-licence
cd apply-for-a-juggling-licence
```

### 2. Setup Ruby and Node with asdf

```bash
asdf plugin add ruby || asdf plugin update ruby
asdf plugin add nodejs || asdf plugin update nodejs
asdf local ruby 4.0.2
asdf local nodejs 24.14.0
asdf install
gem install rails
```

### 3. Setup Yarn

```bash
corepack enable
yarn set version stable
echo "nodeLinker: node-modules" >> .yarnrc.yml
```

### 4. Run rails new with the template

```bash
rails new . \
  --skip-action-mailer \
  --skip-hotwire \
  --skip-jbuilder \
  --skip-test \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-action-cable \
  --skip-active-storage \
  --skip-kamal \
  --no-rc \
  --database=postgresql \
  --javascript=esbuild \
  --css=sass \
  -m https://raw.githubusercontent.com/DFE-Digital/rails-template/main/template.rb
```

The template will apply the full default stack: GOV.UK frontend, RSpec, linting, ADR support, semantic logging, Docker, and more.

### 5. Verify it works

```bash
bin/ci                    # Run the full test suite and linters
bin/setup                 # Setup databases and runs dev server
open http://localhost:3000
```

Check the commit history to see what the template changed. Build the Docker image to make sure it works (see comments in the `Dockerfile`).

### Working with the generated project

```bash
bin/dev                   # Run the app with Foreman
bin/setup                 # Reset databases and logs
bin/ci                    # Run tests and linters

# Production
bin/rails db:create RAILS_ENV=production
docker build .
docker run --net=host \
  -e RAILS_ENV=production \
  -e RAILS_SERVE_STATIC_FILES=true \
  -e SECRET_KEY_BASE=local \
  <DOCKER_IMAGE_ID>
```

### Support

The DfE Rails template is a community resource. It is supported by
@DfE-Digital. If you run into any problems using it or have ideas for new
features you can [raise an issue](https://github.com/DFE-Digital/rails-template/issues)
or [ask questions on Slack](https://ukgovernmentdigital.slack.com/archives/CR51BN3HP).
