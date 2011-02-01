/*

Define: postgres::server

This resource installs and configure a PostgreSQL server

Parameters:
  $listen_addresses:
    Array of IP adresses to listen on.
  $port:
    TCP port to listen on.
  $max_connections:
    Maximum number of connection allowed to the server.

Actions:
  - Install a PostgreSQL server
  - Generate its configuration file with given parameters.

Sample usage:
postgres::server {
  conf:
    listen_addresses	=> ['10.12.13.14','127.0.0.1'],
    max_connections	=> 230;
}
*/
define postgres::server(
  $listen_addresses=['127.0.0.1'],
  $max_connections=100,
  $port=5432
) {
  # Install server.
  include postgres

  # Configure it.
  file {
    '/etc/postgresql/8.3/main/postgresql.conf':
      content	=> template('postgresql/postgresql.conf.erb'),
      notify	=> Service['postgres'];
  }
}
