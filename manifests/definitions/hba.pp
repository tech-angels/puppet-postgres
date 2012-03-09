/*

Define: postgres::hba::common

This resource sets correct owner and permitions on the HBA file

Sample usage:
shouldn't be used directly
*/
define postgres::hba::common(
$version
) {
  file {
    "/etc/postgresql/${version}/main/pg_hba.conf":
      owner	=> 'postgres',
      mode	=> 0400;    
  }
}

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
   if (!defined(Postgres::Hba::Common[$version])) {
     postgres::hba::common {
       $version:
         version	=> $version
     }
   }
  
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
  $ips:
    IP in the form IP/suffix. Exemple: 10.1.1.0/24.
    Or array of IPs. Exemple: ['127.0.0.1/32', '10.1.1.0/24']
  $user:
    Username to allow.
  $version:
    Version of postgresql to install into. (exemple: '8.3', '8.4' ...)
  $ssl:
    Optional. "ssl" or "nossl".
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
    ips		=> '192.168.0.5',
    auth_method	=> 'md5';
}
*/
define postgres::hba::host(
  $database,
  $user,
  $version='8.3',
  $ssl='',
  $ips,
  $auth_method,
  $auth_options=[]
) {
   if (!defined(Postgres::Hba::Common[$version])) {
     postgres::hba::common {
       $version:
         version	=> $version
     }
   }

   case $ssl {
     'ssl','nossl','': {}
     default: {
       fail("ssl parameter must be 'nossl', 'ssl' or empty")
     }
   }
 
   common::concatfilepart {
    $name:
      require	=> Package['postgresql'],
      file	=> "/etc/postgresql/${version}/main/pg_hba.conf",
      content	=> template('postgresql/pg_hba.conf.host.erb'),
      manage	=> true,
      notify	=> Service['postgresql'];
  }  
}
