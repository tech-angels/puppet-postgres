/*

Define: postgres::server

This resource installs and configure a PostgreSQL server

Parameters:
  listen_addresses:
    Array of IP adresses to listen on.
  port:
    TCP port to listen on.
  version:
    8.3 for lenny's postgres.
    8.4 for lenny-backports' postgres
  max_connections:
    Maximum number of connection allowed to the server.
  shared_buffers
    shared buffer in MB (see PostgreSQL doc)
  effective_cache_size 
    effective cache size in MB (see PostgreSQL doc)

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
  $version='8.3',
  $port=5432,
  $shared_buffers=256,
  $effective_cache_size=256
) {
  # Install server.
  case $version {
    '8.3': {
      case $operatingsystem {
        debian: {
          case $lsbdistcodename {
            lenny: {
              # Install lenny package
              package {
               'postgresql':
                 ensure => installed;
              }
              service {
                "postgresql-8.3":
                  require	=> Package['postgresql'],
                  alias		=> 'postgres',
                  ensure	=> running,
                  enable	=> true,
                  hasstatus	=> true;
              }
            }

            default: {
              fail "PostgreSQL 8.3 is unavailable on Debian '${lsbdistcodename}'"
            }
          }
        }
 
        default: {
          fail "Unsupported OS ${operatingsystem} in 'postgres' module"
        }
      }
    }
    '8.4': {
      case $operatingsystem {
        debian: {
          case $lsbdistcodename {
            lenny: {
              # Install lenny-backports Postgres
              os::backported_package{
                ['postgresql', 'postgresql-8.4', 'libpq5', 'postgresql-client-8.4', 'postgresql-common', 'postgresql-client-common']:
                  ensure	=> installed;
              }
              service {
                "postgresql":
                  require	=> Package['postgresql'],
                  ensure	=> running,
                  enable	=> true,
                  hasstatus	=> true;
              }
            }
            squeeze: {
              # Install squeeze package
              package {
               'postgresql':
                 ensure => installed;
              }
              service {
                "postgresql":
                  require	=> Package['postgresql'],
                  alias		=> 'postgres',
                  ensure	=> running,
                  enable	=> true,
                  hasstatus	=> true;
              }
            }

            default: {
              fail "PostgreSQL 8.4 is unavailable on Debian '${lsbdistcodename}'"
            }
          }
        }

        default: {
          fail "Unsupported OS ${operatingsystem} in 'postgres' module"
        }
      }
    }
    default: {
      fail "Unknown value '$version' for version parameter."
    }
  }

  # creates /var/backups/postgresql directory
  file {
    '/var/backups/postgresql':
      mode	=> 1777,
      ensure	=> directory;
  }

  # Create an exported resource job and fileset that the bacula director can realize on his side
  @@bacula-dir::postgresql_backup {
    $hostname:
      client		=> "${hostname}-fd",
      jobdefs		=> 'DefaultJob',
      pool		=> 'DefaultPool',
      bacula_schedule	=> 'DefaultSchedule',
      ensure		=> present;
  }

  # Add default pb_hba configuration
  postgres::hba::local {
    '001 Database administrative login by UNIX sockets': 
      database		=> 'all',
      user		=> 'postgres',
      version		=> $version,
      auth_method	=> 'ident',
      auth_options	=> $version ? {
        '8.3'	=> ['sameuser'],
        default	=> []
      };
  }
  postgres::hba::host {
    '002 IPv4 local connections':
      database		=> 'all',
      user		=> 'all',
      version		=> $version,
      ips		=> '127.0.0.1/32',
      auth_method	=> 'md5';
    '003 IPv6 local connections':
      database		=> 'all',
      user		=> 'all',
      version		=> $version,
      ips		=> '::1/128',
      auth_method	=> 'md5';
  }


  
  # Configure it.
  file {
    "/etc/postgresql/${version}/main/postgresql.conf":
      require	=> Package['postgresql'],
      content	=> $version ? {
        '8.3'	=> template('postgresql/postgresql.conf.erb'),
        '8.4'	=> template('postgresql/postgresql.conf.8.4.erb')
      },
      owner	=> 'postgres',
      notify	=> Service['postgresql'];
  }
}
