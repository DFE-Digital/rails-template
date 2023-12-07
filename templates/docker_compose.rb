template('docker-compose.yml','docker-compose.yml')
append_to_file(
  'docker-compose.yml',
  <<~MD
    # services:
    # db:
    #   image: "postgres:#{ENV["ASDF_POSTGRES_VERSION"]}-alpine"
    #   environment:
    #     POSTGRES_HOST_AUTH_METHOD: "trust"
    #   ports:
    #     - 5432:5432
  MD
)