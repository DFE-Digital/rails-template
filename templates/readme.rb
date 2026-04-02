#!/usr/bin/env ruby

say "  - Setting up README"

remove_file('README.md', verbose: false)
template('template_files/README.tt', 'README.md')
