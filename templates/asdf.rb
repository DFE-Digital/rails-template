template('tool-versions', '.tool-versions')
template('ruby-version', '.ruby-version')

append_to_file(
  'README.md',
  <<~MD
    ## Setup

    Install dependencies using your preferred method, using `asdf` or `rbenv` or
    `nvm`. Example with `asdf`:

    ```bash
    # The first time
    brew install asdf # Mac-specific
    asdf plugin add ruby
    asdf plugin add nodejs
    asdf plugin add yarn

    # To install (or update, following a change to .tool-versions)
    asdf install
    ```
  MD
)
