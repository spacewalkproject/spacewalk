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
package PXT::SoapRequest;

use strict;

use SOAP::Lite;

sub new {
  my $class = shift;

  my $self = bless { }, $class;

  my $serializer = $self->{serializer} = new SOAP::Server;

  return $self;
}

sub decode_rpc_params {
  my $self = shift;
  my $body = shift;

  my $request = $self->{serializer}->deserializer->deserialize($body);
  $request->match((ref $request)->method);
  my $method_name = $request->dataof->name;

  my @params;
  push @params, $method_name;
  push @params, $request->paramsin;

  return \@params;
}

sub encode_rpc_result {
  my $self = shift;
  my $pxt = shift;

  my $serializer = $self->{serializer}->serializer;
  $serializer->prefix('s');

  my $ret = $serializer->envelope(response => "foo.bar", @_);

  return $ret;
}

sub encode_rpc_fault {
  my $self = shift;
  my $code = shift;
  my $message = shift;

  my $ret = $self->{serializer}->make_fault("rhn-rpc-fault:$code", $message);

  return $ret;
}

1;
