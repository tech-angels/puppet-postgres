/*

define: postgres::continuous-archiving

This resource sets up continuous archiving as descrived in
http://www.postgresql.org/docs/8.3/static/continuous-archiving.html

Parameters:
- version: PostgreSQL version
- wal_directory: directory where to copy the WAL to.
- backup_directory: directory where to put backups

*/
define postgres::continuous-archiving(
$version='9.0',
$wal_directory='/var/lib/postgresql-wal',
$backup_directory='/var/backups/postgresql-wal-backup'
) {
  include postgres::continuous-archiving::common

  # Create wal directory
  if (!defined(File[$wal_directory])) {
    file {
      $wal_directory:
        owner	=> 'postgres',
        group	=> 'postgres',
        mode	=> 0755,
        ensure	=> directory;
    }
  }

  # Create backup dir
  file {
    $backup_directory:
      owner	=> 'postgres',
      group	=> 'postgres',
      mode	=> 0700,
      ensure	=> directory;
  }

  # PostgreSQL continuous archiving configuration
  common::concatfilepart {
    "postgresql-conf-010-continuous-archiving":
      require	=> Package['postgresql'],
      notify	=> Service['postgresql'],
      file      => "/etc/postgresql/${version}/main/postgresql.conf",
      manage    => true,
      content	=> template('postgresql/continuous-archiving.conf.erb');
  }
}


