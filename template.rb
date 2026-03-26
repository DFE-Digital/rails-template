fail("Rails 7.0.0 or greater is required") if Rails.version <= "7"

def apply_template!
  add_template_repository_to_source_path

  setup_readme
  setup_dependabot

  setup_frontend
  setup_test_suite

  add_quite_deps_for_sass

  add_docker
  add_docker_compose

  setup_linting
  setup_solargraph # Needs to come after linting
  setup_adrs # Put last for correct ordering in README
  setup_semantic_logger

  after_bundle do
    initialize_git
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
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def setup_readme
  apply 'templates/readme.rb'
end

def setup_dependabot
  template('dependabot.yml', '.github/dependabot.yml')
end

def setup_frontend
  apply "templates/frontend.rb"
end

def setup_test_suite
  apply 'templates/test_suite.rb'
end

def add_quite_deps_for_sass
  return if file_contains?('package.json', '--quiet-deps')

  gsub_file(
    'package.json',
    /--load-path=node_modules/,
    '--load-path=node_modules --quiet-deps'
  )
end

def add_docker
  say "\n=== Docker ==="
  template('Dockerfile')
  template('dockerignore', '.dockerignore')
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
  return say('solargraph already setup, skipping') if file_exists?('.solargraph.yml')
  say("\n=== solargraph https://solargraph.org/ ===")
  return unless yes?('Add solargraph for Ruby intellisense support? y/N')

  apply 'templates/solargraph.rb'
end

def setup_adrs
  return say('ADRs already setup, skipping') if file_contains?('Gemfile', 'rladr')
  say("\n=== Architecture Decision Records (ADRs) ===")
  return unless yes?('Add `rladr` for Architecture Decision Record (ADR) support? y/N')

  apply 'templates/adr.rb'
end

def setup_semantic_logger
  say("\n=== semantic logger https://logger.rocketjob.io/ ===")

  apply 'templates/semantic_logger.rb'
end

def initialize_git
  template('gitignore', '.gitignore')

  git(init: "--initial-branch=main")
  git(add: ".")
  git(commit: <<~COMMIT)
    -m "Initial commit

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
