/*

Define: postgres::hba::local

This resource represents a host based authentication line for a local client.
(see http://developer.postgresql.org/pgdocs/postgres/auth-pg-hba-conf.html )

Parameters:
  $database:
    Database to access.
  $user:
    Username to allow.
  $version:
    Version of postgresql to install into. (exemple: '8.3', '8.4' ...)
  $auth_method:
    Authentication method.
  $auth_options:
    Array of name=value options for the chosen auth method.

Actions:
  - Adds a line in the pg_hba.conf file.
  - Reloads Postgres.

Sample usage:
postgres::hba::local {
  '01 local access to dev_db for dev_usr':
    database	=> 'dev_db',
    user	=> 'dev_usr',
    auth_method	=> 'md5';
}
*/
define postgres::hba::local(
  $database,
  $user,
  $version='8.3',
  $auth_method,
  $auth_options=[]
) {
   common::concatfilepart {
    $name:
      require	=> Package['postgresql'],
      file	=> "/etc/postgresql/${version}/main/pg_hba.conf",
      content	=> template('postgresql/pg_hba.conf.local.erb'),
      manage	=> true,
      notify	=> Service['postgresql'];
  }  
}

/*

Define: postgres::hba::host

This resource represents a host based authentication line for a tcp client.
(see http://developer.postgresql.org/pgdocs/postgres/auth-pg-hba-conf.html )

Parameters:
  $database:
    Database to access.
  $ip:
    IP in the form IP/suffix. Exemple: 10.1.1.0/24.
  $user:
    Username to allow.
  $version:
    Version of postgresql to install into. (exemple: '8.3', '8.4' ...)
  $auth_method:
    Authentication method.
  $auth_options:
    Array of name=value options for the chosen auth method.

Actions:
  - Adds a line in the pg_hba.conf file.
  - Reloads Postgres.

Sample usage:
postgres::hba::host {
  '01 local access to dev_db for dev_usr':
    database	=> 'dev_db',
    user	=> 'dev_usr',
    ip		=> '192.168.0.5',
    auth_method	=> 'md5';
}
*/
define postgres::hba::host(
  $database,
  $user,
  $version='8.3',
  $ip,
  $auth_method,
  $auth_options=[]
) {
   common::concatfilepart {
    $name:
      require	=> Package['postgresql'],
      file	=> "/etc/postgresql/${version}//main/pg_hba.conf",
      content	=> template('postgresql/pg_hba.conf.host.erb'),
      manage	=> true,
      notify	=> Service['postgresql'];
  }  
}
