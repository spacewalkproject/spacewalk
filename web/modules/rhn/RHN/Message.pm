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

package RHN::Message;

use strict;
use RHN::ServerMessage;
use RHN::TextMessage;
use RHN::Utils;
use RHN::DB::Message;

our @ISA = qw/RHN::DB::Message/;

sub get_user_messages {
  my $class = shift;
  my @attr = @_;

  my $messages = RHN::DB::Message->user_messages(@attr);
  my @messages = ( );

  if (ref $messages and @{$messages} > 0) {
    @messages = RHN::Utils->parameterize($messages, qw/id type priority status server_id server_event body created modified/)
  }

  return [ @messages ];
}

sub lookup {
  my $class = shift;
  my $message_id = shift;

  my $msg = RHN::DB::Message::TextMessage->lookup_message($message_id);

  return $msg if defined $msg;

  $msg = RHN::DB::Message::ServerMessage->lookup_message($message_id);

  return $msg;
}

1;
