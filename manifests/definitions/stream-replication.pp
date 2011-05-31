/*

define: postgres::stream-replication::master

*/
define postgres::stream-replication::master(
$version='9.0',
$wal_directory='/var/lib/postgresql-wal'
) {
  # Create wal directory
  file {
    $wal_directory:
      owner	=> 'postgres',
      group	=> 'postgres',
      mode	=> 0700,
      ensure	=> directory;
  }

  # purge WAL directory of old files automaticaly
  cron {
    'purge WAL directory of old files':
      command	=> "/usr/bin/find $wal_directory -type f -and -mtime +2 -exec rm -f {} \\;",
      user	=> 'postgres',
      minute	=> 15,
      hour	=> 6;
  }

  # PostgreSQL master SR Configuration
  common::concatfilepart {
    "postgresql-conf-010-sr-master":
      require	=> Package['postgresql'],
      notify	=> Service['postgresql'],
      file      => "/etc/postgresql/${version}/main/postgresql.conf",
      manage    => true,
      content	=> template('postgresql/sr-master.conf.erb');
  }
}

define postgres::stream-replication::slave(
$version='9.0',
$master_host,
$master_port='5432',
$recovery_conf_path=false,
$restore_command=false,
$wal_directory='/var/lib/postgresql-wal'
) {
  if $recovery_conf_path {
    $real_recovery_conf_path=$recovery_conf_path
  } else {
    $real_recovery_conf_path='/var/lib/postgresql/9.0/main/recovery.conf'
  }

  if $restore_command {
    $real_restore_command=$restore_command
  } else {
    # By default, use RSYNC to copy WAL files from master
    $real_restore_command="/usr/bin/rsync postgres@${master_host}:${wal_directory}/%f \"%p\""
  }  

  # PostgreSQL slave SR Configuration
  common::concatfilepart {
    "postgresql-conf-010-sr-slave":
      require	=> Package['postgresql'],
      notify	=> Service['postgresql'],
      file      => "/etc/postgresql/${version}/main/postgresql.conf",
      manage    => true,
      content	=> template('postgresql/sr-slave.conf.erb');
  }

  # recovery.conf file
  file {
    $real_recovery_conf_path:
      owner	=> 'postgres',
      group	=> 'postgres',
      mode	=> 0400,
      require   => Package['postgresql'],
      notify    => Service['postgresql'],
      content	=> template('postgresql/recovery.conf.erb');
  }
}
