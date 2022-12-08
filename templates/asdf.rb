template('tool-versions', '.tool-versions')

run "asdf plugin add ruby || true"
run "asdf plugin add nodejs || true"
run "asdf plugin add yarn || true"
run "asdf plugin add postgres || true"
run "asdf install"

postgres_version = get_tools_version_of("postgres")

append_to_file(
  'README.md',
  <<~MD
    ### asdf

    This project uses `asdf`. Use the following to install the required tools:

    ```sh
    # The first time
    brew install asdf # Mac-specific
    asdf plugin add ruby
    asdf plugin add nodejs
    asdf plugin add yarn
    asdf plugin add postgres

    # To install (or update, following a change to .tool-versions)
    asdf install
    ```

    When installing the `pg` gem, bundle changes directory outside of this
    project directory, causing it lose track of which version of postgres has
    been selected in the project's `.tool-versions` file. To ensure the `pg` gem
    installs correctly, you'll want to set the version of postgres that `asdf`
    will use:

    ```sh
    # Temporarily set the version of postgres to use to build the pg gem
    ASDF_POSTGRES_VERSION=#{postgres_version} bundle install
    ```

  MD
)
