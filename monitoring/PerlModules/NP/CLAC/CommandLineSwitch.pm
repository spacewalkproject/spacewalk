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

=head1 NAME

NOCpulse::CommandLineSwitch - Represents a command line switch as used in CommandLineApplicationComponent.


=head1 DESCRIPTION

Switch definition includes a Getopt::Long
spec, a required switch, a default value, and short documentation.  Logic 
includes switch validation and documentation.

Note that this class is designed to be used with CommandLineApplicationComponent, 
and as such it's very unlikely that you'll ever directly interact with it or it's
instances.

=head1 REQUIRES

NOCpulse::Object, Getopt::Long, Text::Wrap

=head1 EXPORTS

nothing

=cut

package NOCpulse::CommandLineSwitch;
use strict;
use vars qw(@ISA);
use NOCpulse::Object;
use Getopt::Long;
use Text::Wrap qw(wrap);
@ISA=qw(NOCpulse::Object);

# Turn off GetOpt's auto-abbreviation feature (which breaks
# options processing in this context).
Getopt::Long::Configure('no_auto_abbrev');


=head1 INSTANCE METHODS

=over 4

=cut


sub instVarDefinitions
{

=item instVarDefinitions()


Defines the following variables:


   name - the name of the switch as it will appear in help and as it should be typed by the user

   spec - specification of the contents of the switch a la Getopt::Long

   required - whether or not this switch must be used (does not make much sense if there's a default value)

   default - default value for this switch

   value - the actual value of the switch after parsing

   usage - string describing what this switch means and how it should be used

   validated - whether or not this switch has been validated

   isValid - whether or not this switch's value is valid given the spec and required

=cut

        my $self = shift();
	$self->addInstVar('name');
	$self->addInstVar('spec');
	$self->addInstVar('required');
	$self->addInstVar('default');
	$self->addInstVar('value');
	$self->addInstVar('usage');
	$self->addInstVar('validated');
	$self->addInstVar('isValid');
	$self->addInstVar('isMissing');
	$self->addInstVar('isWrongType');
}

sub initialize
{
	my ($self,$name,$spec,$required,$default,$usage) = @_;
	$self->set_name($name);
	$self->set_spec($spec);
	$self->set_required($required);
	$self->set_default($default);
	$self->set_value($default);
	$self->set_usage($usage);
	$self->set_validated(0);
	$self->set_isWrongType(0);
	$self->set_isMissing(1);
	$self->set_isValid(0);
	return $self;
}


sub isValid
{

=item isValid(<component>)

Reports the validity of the switch's state.  Requires that you pass in the instance
of the component that defines/owns the switch (done for you by CommandLineApplicationComponent)

Returns true if:

   - Getopt::Long is (or was - results are cached) happy with the value as regards the spec

Returns false if:

   - Getopt::Long is unhappy with the switch value as regards the spec

   OR

   - The switch is required and there's no default and the user provides no value and the
   command line application component provides no value via  get_xxx (where 
   xxx is the name of this switch).

=cut

        my ($self,$component) = @_;
	if (! $self->get_validated) {
		# Getopt's pass_through mode does not handle type mismatches in
		# arguments, so the workaround here is to save ARGV and run regular
		# GetOptions with a sub that remembers this switch's value.
		my $value;
		my $typeError = 0;
		my @prevArgs = @ARGV;

		# Type errors are tracked by looking for "invalid" in the
		# warning string from GetOptions, which is a VERY BAD THING, but
		# appears to be the only way to distinguish this case from a missing value.
		local $SIG{__WARN__} = sub { if ($_[0] =~ /invalid/) { $typeError = 1; } };

		GetOptions($self->get_name.$self->get_spec, sub { $value = $_[1] });
		@ARGV = @prevArgs;

		$self->set_validated(1);

		#print "Switch ".$self->get_name.": parse args ".join(' ', @ARGV)."\n";

		if (defined($value)) {
			$self->set_isMissing(0);
			$self->set_isWrongType(0);
			$self->set_value($value);
		} else {
                        $self->set_value($self->get_default);
			if ($typeError) {
				$self->set_isMissing(0);
				$self->set_isWrongType(1);
			} elsif ($self->get_required
				 && (! $component->has($self->get_name))
				 && (! $component->can('get_'.$self->get_name)))
			{
				$self->set_isMissing(1);
				$self->set_isWrongType(0);
			} else {
				$self->set_isMissing(0);
			}
		}
		$self->set_isValid((! $self->get_isMissing) && (! $self->get_isWrongType));
	}
	return $self->get_isValid;
}

sub usage
{

=item usage(<component>)

Returns a string that stands as documentation for the switch.  Requires that you pass in the 
CommandLineApplicationComponent that defined/owns it.  (Done for you by CommandLineApplicationComponent)

=cut

	my ($self,$component) = @_;

        my $result = "--".$self->get_name.$self->get_spec.' ';
 	if ($self->get_required) {
                 if ($component->has($self->get_name)) {
                    $result .= '(requirement satisfied internally but overridable)';
                 } else {
                    $result .= '*required* ';
                 }
 	}
 	if ($self->get_default) {
 		$result .= '(default='.$self->get_default.') ';
         }
 	if ($self->get_usage) {
 		$result .= ": ".$self->get_usage;
 	}
         if (! $self->isValid($component)) {
            $result .= " [INVALID value: '".$self->get_value."'] "
         } else {
            $result .= " [value: '".$self->get_value."'] ";
         }
 	$result .= "\n";
 	return wrap('',"\t",$result);
}

sub specAsType
{

=item specAsType

Returns a string that describes this switch's data type

=cut

	my $self = shift();
	my $spec = $self->get_spec;
	return 'integer' if ($spec =~ /i/);
	return 'float' if ($spec =~ /f/);
	return 'string';
}

sub usageAsSql
{

=item usageAsSql(<component>)

Returns a string that updates NOCpulse tables as to the usage of this particular switch

=cut

	my ($self,$component) = @_;
	my $sql = "update command_parameter set ";
	if (! $component->can('get_'.$self->get_name)) {
		if ($self->get_name =~ /pass|community/i) {
		  $sql .= "data_type_name = 'password',";
		} else {
		  $sql .= "data_type_name = '".$self->specAsType."',";
		}
		$sql .= "mandatory = ";
		if ($self->get_required) {
			$sql .= "'1'";
		} else {
			$sql .= "'0'";
		}
	} else {
		$sql .= "field_visible = '0'";
	}
	$sql .= " where param_name = '".$self->get_name;
	$sql .= "' and command_id in (select recid from command where command_class = '".ref($component)."');";
	return $sql;
}

sub invalidSwitchAsXML
{

=item invalidSwitchAsXML(<component>)

Returns a string that produces the switch documentation in XML format, used during satellite
configuration.

=cut

	my ($self,$component) = @_;
	if (! $component->can('get_'.$self->get_name)) {
		if (! $self->isValid($component)) {
			my $result = "<switch ";
			$result .= 'name="'.$self->get_name.'" ';
			$result .= 'default="'.$self->get_default.'" ';
			$result .= 'value="'.$self->get_value.'" ';
			$result .= 'status="';
			$result .= ($self->get_isMissing ? "missing" : "invalid");
			$result .= '"/>';
			return $result;
	      }
	}
	return '';
}

sub hasProblem
{
	my ($self,$component) = @_;
	if (! $component->can('get_'.$self->get_name)) {
	   return (! $self->isValid($component));
	}
}

1;
