/*

Define: postgres::server::conf

This resource installs configuration in the postgres server

*/
define postgres::server::conf(
$version,
$content=undef,
$source=undef
) {
  common::concatfilepart {
    "postgresql-conf-010-${name}":
      require	=> Package['postgresql'],
      notify	=> Service['postgresql'],
      file      => "/etc/postgresql/${version}/main/postgresql.conf",
      manage    => true,
      content	=> $content,
      source	=> $source;
  }
}
