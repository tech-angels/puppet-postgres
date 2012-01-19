/* 

Class: postgres::continuous-archiving::common

*/
class postgres::continuous-archiving::common {
  # Backup script
  file {
    '/usr/local/sbin/backup_postgres_wal':
      owner	=> 'postgres',
      group	=> 'postgres',
      mode	=> 0700,
      source	=> 'puppet:///modules/postgresql/backup_postgres_wal';
  }
}
