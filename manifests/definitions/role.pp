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

/*

Define: postgres::role

This resource manages roles in PostgreSQL.

Parameters:
  $name:
    Name of role.
  $ensure:
    present to create role.
    absent to remove role.
  $password:
    Password of role.
  $createdb:
    true to allow role to create databases.
    false to not allow.
  $login:
    true to allow role to login.
    false to not allow.

Actions:
  * create or remove role
  * allow or disallow createdb or login

Sample usage:
postgres::role {
  'dev_usr':
    password	=> 'DR7468b',
    createdb	=> true;
}
*/
define postgres::role(
  $ensure,
  $password=false,
  $createdb=false,
  $login=false
) {
    $passtext = $password ? {
        false => "",
        default => "PASSWORD '$password'"
    }
    case $ensure {
        present: {
            # The createuser command always prompts for the password.
            exec { "Create $name postgres role":
                command => "/usr/bin/psql -c \"CREATE ROLE $name $passtext\"",
                user => "postgres",
                unless => "/usr/bin/psql -c '\\du' | grep '^  *$name  *|'"
            }
            # Give or remove createdb privilege
            case $createdb {
              true: {
                exec { "Give createdb to $name postgres role":
                  command => "/usr/bin/psql -c \"ALTER ROLE $name WITH CREATEDB\"",
                  user => "postgres",
                  unless => "/usr/bin/psql -A -c '\\du' |grep '${name}' | cut -d\| -f 4 |grep ^yes\$";
                }
              }
              false: {
                 exec { "Remove createdb from $name postgres role":
                  command => "/usr/bin/psql -c \"ALTER ROLE $name WITH NOCREATEDB\"",
                  user => "postgres",
                  onlyif => "/usr/bin/psql -A -c '\\du' |grep '${name}' | cut -d\| -f 4 |grep ^yes\$";
                }
              }
              default: {
                fail "Invalid 'createdb' value '$createdb' for postgres::role"
              }
            }
            # Give or remove login privilege
            case $login {
              true: {
                exec { "Give login to $name postgres role":
                  command => "/usr/bin/psql -c \"ALTER ROLE $name WITH LOGIN\"",
                  user => "postgres",
                  unless => "/usr/bin/psql -Atc \"SELECT rolcanlogin FROM pg_roles WHERE rolname='${name}'\" |grep ^t\$";
                }
              }
              false: {
                 exec { "Remove login from $name postgres role":
                  command => "/usr/bin/psql -c \"ALTER ROLE $name WITH NOLOGIN\"",
                  user => "postgres",
                  onlyif => "/usr/bin/psql -Atc \"SELECT rolcanlogin FROM pg_roles WHERE rolname='${name}'\" |grep ^t\$";
                }
              }
              default: {
                fail "Invalid 'createdb' value '$createdb' for postgres::role"
              }
            }
 
        }
        absent:  {
            exec { "Remove $name postgres role":
                command => "/usr/bin/dropeuser $name",
                user => "postgres",
                onlyif => "/usr/bin/psql -c '\\du' | grep '$name  *|'"
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for postgres::role"
        }
    }
}
