# Copyright (c) 2008, Luke Kanies, luke@madstop.com
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

class postgres {
  package {
    'postgresql':
      ensure => installed;
  }

  service {
    'postgresql-8.3':
      alias	=> 'postgres',
      ensure	=> running,
      enable	=> true,
      hasstatus	=> true;
  }

  # Add default pb_hba configuration
  common::concatfilepart {
    '000-pg_hba.conf-header':
      file	=> '/etc/postgresql/8.3/main/pg_hba.conf',
      content	=> "# File managed by Puppet\n",
      manage	=> true;
  }
  postgres::hba::local {
    '001 Database administrative login by UNIX sockets':
      database		=> 'all',
      user		=> 'postgres',
      auth_method	=> 'ident',
      auth_options	=> ['sameuser'];
  }
  postgres::hba::host {
    '002 IPv4 local connections':
      database		=> 'all',
      user		=> 'all',
      ip		=> '127.0.0.1/32',
      auth_method	=> 'md5';
    '003 IPv6 local connections':
      database		=> 'all',
      user		=> 'all',
      ip		=> '::1/128',
      auth_method	=> 'md5';
  }
}
