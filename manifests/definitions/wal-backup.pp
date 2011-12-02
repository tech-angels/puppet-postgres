define postgres::wal-backup (
  $version,
  $cluster='main',
  $minute=undef,
  $hour=undef,
  $month=undef,
  $monthday=undef,
  $weekday=undef,
  $ensure='present'
) {
  # Backup PostgreSQL at specified times
  if !defined(File['/usr/local/sbin/postgresql-wal-backup']) {
    file { '/usr/local/sbin/postgresql-wal-backup':
      owner   => 'postgres',
      group   => 'postgres',
      mode    => 0500,
      content => template('postgresql/postgresql-wal-backup.erb'),
    }
  }

  cron { "backup-postgresql-with-wal $name":
    command  => '/usr/local/sbin/postgresql-wal-backup',
    user     => 'postgres',
    minute   => $minute,
    hour     => $hour,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
    ensure   => $ensure,
  }
}
