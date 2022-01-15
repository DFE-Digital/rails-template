# Rails 7 application template

This is an application template for starting Ruby on Rails applications with GOV.UK Frontend packaged and ready to go.

## What's included

* asset bundling via [esbuild](https://esbuild.github.io/)
* [GOV.UK Components](https://govuk-components.netlify.app/)
* [GOV.UK Form Builder](https://govuk-form-builder.netlify.app/)
* [RSpec](https://rspec.info/)

## Requirements

* Rails 7.0.1
* Ruby 3.1.0 (older versions _probably_ work but haven't been tested)
* [Foreman](https://github.com/ddollar/foreman)
* [NodeJS](https://nodejs.org/en/)
* [Yarn](https://yarnpkg.com/)

## Things that will be added soon

* a Dockerfile
* GOV.UK PaaS config
* FormBuilder setup and config

## Example use

To generate a new application called `blog`:

```sh
rails new                                                                          \
  --skip-bundle                                                                    \
  --skip-jbuilder                                                                  \
  --skip-test                                                                      \
  --skip-action-text                                                               \
  --skip-action-mail{er,box}                                                       \
  -m https://raw.githubusercontent.com/DFE-Digital/rails-template/main/template.rb \
  blog
```
