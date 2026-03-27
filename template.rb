fail("Rails 7.0.0 or greater is required") if Rails.version <= "7"

def apply_template!
  add_template_repository_to_source_path

  template('template_files/gitignore', '.gitignore', force: true)

  after_bundle do
    pre_template_commit

    ensure_node_version_set

    setup_readme
    setup_dependabot

    configure_generators

    setup_frontend
    setup_test_suite

    add_docker
    add_docker_compose

    setup_linting
    setup_solargraph # Needs to come after linting
    setup_adrs # Put last for correct ordering in README
    setup_semantic_logger

    fix_ci
    fix_setup
    bundle_with_checksums
    apply_rubocop_fixes

    post_template_commit
  end
end

# Taken from https://github.com/mattbrictson/rails-template/blob/215a87d00ff2b2a656be3ebd277e7f71607f5d49/template.rb#L99
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/DFE-Digital/rails-template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      say("==BRANCH: #{branch}", :blue)
      Dir.chdir(tempdir) { git checkout: branch.gsub("refs/heads/", "") }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def pre_template_commit
  say "\n=== Creating pre-template commit ==="
  git(add: ".")
  git(commit: <<~COMMIT)
    -m "Pre template commit

    Rails new commit, before we start applying the template"
  COMMIT
end

def ensure_node_version_set
  say "\n=== Setting Node version ==="
  return if file_contains?("package.json", "engines")

  node_engine_config = <<-JSON
  
  "engines": {
    "node": "^#{node_version}"
  },
      JSON

  insert_into_file("package.json", node_engine_config, after: "{")
end

def setup_readme
  say "\n=== Setting up README ==="
  apply 'templates/readme.rb'
end

def setup_dependabot
  say "\n=== Setting up Dependabot ==="
  template('template_files/dependabot.yml', '.github/dependabot.yml', force: true)
end

def configure_generators
  say "\n=== Configuring generators ==="
  initializer "generators.rb", <<-RUBY
  Rails.application.config.generators do |g|
    g.test_framework :rspec, fixture: false
    g.helper false
    g.stylesheets false
    g.scaffold_stylesheet false
    g.template_engine :erb
    
    # Don't generate system test files.
    g.view_specs false
    g.helper_specs false
    
    # Uncomment to configure generators to use ULID primary keys
    # g.orm :active_record, primary_key_type: :string
  end

  RUBY
end

def setup_frontend
  say "\n=== Setting up GOV.UK Frontend ==="
  apply "templates/frontend.rb"
end

def setup_test_suite
  say "\n=== Setting up test suite ==="
  apply 'templates/test_suite.rb'
end

def add_docker
  say "\n=== Docker ==="
  template('template_files/Dockerfile', 'Dockerfile', force: true)
  template('template_files/dockerignore', '.dockerignore', force: true)
  remove_file("bin/docker-entrypoint")
end

def add_docker_compose
  say "\n=== Docker Compose ==="
  apply 'templates/docker_compose.rb'
end

def setup_linting
  say("\n=== Rubocop and prettier ===")

  apply 'templates/linting.rb'
end

def setup_solargraph
  say("\n=== solargraph https://solargraph.org/ ===")

  apply 'templates/solargraph.rb'
end

def setup_adrs
  say("\n=== Architecture Decision Records (ADRs) ===")

  apply 'templates/adr.rb'
end

def setup_semantic_logger
  say("\n=== semantic logger https://logger.rocketjob.io/ ===")

  apply 'templates/semantic_logger.rb'
end

def fix_ci
  say "\n=== Fixing CI configuration ==="
  gsub_file("config/ci.rb", "yarn audit", "yarn npm audit")
end

def fix_setup
  say "\n=== Fixing setup script ==="
  gsub_file("bin/setup", "yarn install --check-files", "yarn install")
end

def bundle_with_checksums
  say "\n=== Adding checksums to Gemfile.lock ==="
  run("bundle lock --add-checksums")
end

def apply_rubocop_fixes
  say "\n=== Running Rubocop fixes ==="
  run("bin/rubocop --autocorrect-all --format quiet")
end

def post_template_commit
  say "\n=== Creating post-template commit ==="
  git(add: ".")
  git(commit: <<~COMMIT)
    -m "Post template commit

    Built using the Department for Education's Rails template"
  COMMIT
end

def file_exists?(file)
  File.exist?(file)
end

def file_contains?(file, contains)
  return false unless file_exists?(file)

  File.foreach(file).any? { |line| line.include?(contains) }
end

apply_template!
