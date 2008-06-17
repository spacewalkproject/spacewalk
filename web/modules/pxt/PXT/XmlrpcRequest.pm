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
package PXT::XmlrpcRequest;

use strict;

use Frontier::RPC2;

sub new {
  my $class = shift;

  my $self = bless { }, $class;

  $self->{frontier} = new Frontier::RPC2;

  return $self;
}

sub decode_rpc_params {
  my $self = shift;
  my $body = shift;

  my $call = $self->{frontier}->decode($body);

  my @params = ($call->{method_name}, @{ $call->{value} });
  return \@params;
}

sub encode_rpc_result {
  my $self = shift;
  my $pxt = shift;

  return $self->{frontier}->encode_response(@_ > 1 ? [@_] : @_);
}

sub encode_rpc_fault {
  my $self = shift;
  my $code = shift;
  my $message = shift;

  return $self->{frontier}->encode_fault($code, $message);
}

1;
