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

package RHN::DB::MonitoringConfigMacro;

use strict;
use Carp;
use Data::Dumper;
use RHN::DataSource::Simple;
use RHN::DB;

our $VERSION = (split(/s+/, q$Id$, 4))[2];


# Generated getter/setter methods (per Chip)
{

  my @fields = qw(
    name definition description environment
    last_update_user last_update_date
  );

  my $tmpl = q|
    sub [[field]] {
      my $self = shift;
      if (@_) {
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    };
  |;

  foreach my $field (@fields) {

    (my $sub = $tmpl) =~ s/\[\[field\]\]/$field/g;

    eval $sub;

    croak $@ if($@);
  }

}


#########
sub new {
#########
  my $class = shift;
  my %args  = @_;
  my $self  = {};
  bless($self, $class);

  foreach my $arg (keys %args) {
    $self->$arg($args{$arg});
  }

  return $self;
}


##########################
sub load_editable_macros {
##########################
  my $class = shift;
  my @macros;

  my $data = RHN::DataSource::Simple->new(
              -querybase => 'probe_queries',
              -mode      => 'editable_config_macros',
            )->execute_full();

  foreach my $record (@$data) {
    my $macro = $class->new();
    foreach my $field (keys %$record) {
      my $meth  = lc($field);
      my $value = defined($record->{$field}) ? $record->{$field} : '';
      $macro->$meth($value);
    }
    push(@macros, $macro);
  }

  return \@macros;
}

############
sub update {
############
  my $self  = shift;
  my $login = shift;

  my $dbh = RHN::DB->connect;

  my $sql = q{
    UPDATE rhn_config_macro
    SET    definition = :definition,
           last_update_user = :luser,
           last_update_date = sysdate
    WHERE  name = :name
    AND    environment = :environment
  };

  my $sth = $dbh->prepare($sql);
  $sth->execute_h(
    definition   => $self->definition,
    name         => $self->name,
    environment  => $self->environment,
    luser        => $login,
  );

}


1;


__END__
=head1 NAME

RHN::DB::MonitoringConfigMacro - Monitoring commands

=head1 SYNOPSIS

  use RHN::DB::MonitoringConfigMacro;
  
  my $macros = RHN::DB::MonitoringConfigMacro->load_editable_macros();

  my $macro = $macros->[0];
  $macro->definition($new_definition);
  $macro->update($username);

=head1 DESCRIPTION

RHN::DB::MonitoringConfigMacro provides access to RHN monitoring 
configuration macros (the RHN_CONFIG_MACRO table).

=head1 CLASS METHODS

=over 8

=item new()

Construct a new RHN::DB::MonitoringConfigMacro object.

=item load_editable_macros()

Loads editable macros from the database.

=back

=head1 INSTANCE METHODS

=over 8

=item update($username)

Updates a changed macro in the database.  $username will be recorded
as the last person to edit the macro.

=back

=head1 INSTANCE VARIABLES

=over 8

=item name()

The macro name.

=item definition()

The macro definition.  Macros may refer to other macros using
%{MACRONAME} syntax.

=item description()

The human-readable macro description.

=item environment()

The environment for which the macro is intended.

=item last_update_user()

The last person to update the macro.

=item last_update_date()

The last time the macro was updated.

=back

=head1 COPYRIGHT

Copyright (c) 2004-2005, Red Hat, Inc.  All rights reserved

=cut


