#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

package Sniglets::Debug;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-debug-dump" => \&dump);
}

sub dump {
  my $pxt = shift;

  my @ret;
  push @ret, map { "$_ => " . $pxt->{apr}->$_() } qw/as_string hostname location/;
  push @ret, map { "$_ => " . $pxt->{apr}->server->$_() } qw/server_hostname/;
  push @ret, map { "$_ => " . $pxt->{apr}->connection->$_() } qw/remote_ip remote_host/;

  my @params = $pxt->{apr}->param();
  my $params = "form variables =>\n";
  foreach my $param (@params) {
    $params .= "\t$param:  " . join(', ', $pxt->{apr}->param($param)) . "\n";
  }
  push(@ret, $params);

  my $subp_env = $pxt->{apr}->subprocess_env('HTTPS');
  push @ret, "SSL => $subp_env" if (defined($subp_env));

  push @ret, map { "pxt => " . Data::Dumper->Dump([$pxt])} 1;
  push @ret, map { "pxt_ssl_$_ => " . $pxt->$_()} qw/ssl_available ssl_request/;
  push @ret, map { "pxt_derelative($_) => " . $pxt->derelative_url($_)}
    ("/foo.txt", "bar.txt");


  return join("", map { "<pre>$_</pre>\n" } @ret);
}

1;
