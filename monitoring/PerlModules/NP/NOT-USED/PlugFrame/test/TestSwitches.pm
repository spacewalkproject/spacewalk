use strict;
use Test qw(ok);
use NOCpulse::PlugFrame::CommandLineApplicationComponent;

package TestSwitches;

@TestSwitches::ISA=qw(NOCpulse::PlugFrame::CommandLineApplicationComponent);

my %DEFAULT = { RequiredString => 'foo',
		RequiredInteger => '100',
		RequiredFloat => '199.8'
	      };
my @NAMES = ('RequiredString', 'OptionalInteger',
	     'RequiredInteger', 'OptionalString',
	     'RequiredFloat', 'OptionalFloat');

sub registerSwitches
{
   my $self = shift();
   $self->SUPER::registerSwitches; # good practice
   my $i = 0;
   $self->addSwitch($NAMES[$i], '=s', 1, $DEFAULT{$NAMES[$i++]}, 'Required string');
   $self->addSwitch($NAMES[$i++], ':i', 0, '50', 'Optional integer');
   $self->addSwitch($NAMES[$i], '=i', 1, $DEFAULT{$NAMES[$i++]}, 'Required integer');
   $self->addSwitch($NAMES[$i++], ':s', 0, 'bar', 'Optional string');
   $self->addSwitch($NAMES[$i], '=f', 1, $DEFAULT{$NAMES[$i++]}, 'Required float');
   $self->addSwitch($NAMES[$i++], ':f', 0, '59.8', 'Optional float');
}

my $self;

sub testValid {
   my $outcome = shift;
   my $descr = shift;
   @ARGV = @_;
   $self = TestSwitches->newInitialized;
   Test::ok($self->commandLineIsValid, $outcome, $descr);
   NOCpulse::PlugFrame::CommandLineApplicationComponent::FreeAllInstances;
}

sub argsValid {
   testValid(1, @_);
}

sub argsInvalid {
   testValid(0, @_);
}

sub argOK {
   my ($self, $argName, $descr) = @_;
   Test::ok($self->switch($argName)->get_isMissing, 0, "$descr: Arg $argName missing");
   Test::ok($self->switch($argName)->get_isWrongType, 0, "$descr: Arg $argName has the wrong type");
}

sub argMissing {
   my ($self, $argName, $descr) = @_;
   Test::ok($self->switch($argName)->get_isMissing, 1, "$descr: Arg $argName not missing");
}

sub argWrongType {
   my ($self, $argName, $descr) = @_;
   Test::ok($self->switch($argName)->get_isWrongType, 1,
	    "$descr: Arg $argName does not have the wrong type");
}

sub run {
   # Required strings and type checking
   my $test = 'All required args present';
   argsValid($test, '--RequiredString=abc', '--RequiredInteger=123', '--RequiredFloat=456.78');
   $self->argOK('RequiredString', $test);
   $self->argOK('RequiredInteger', $test);
   $self->argOK('RequiredFloat', $test);

   $test = 'No args';
   argsInvalid($test, '');
   $self->argMissing('RequiredString', $test);
   $self->argMissing('RequiredInteger', $test);
   $self->argMissing('RequiredFloat', $test);

   $test = 'Single arg';
   argsInvalid($test, '--RequiredString=abc');
   $self->argOK('RequiredString', $test);
   $self->argMissing('RequiredInteger', $test);
   $self->argMissing('RequiredFloat', $test);

   $test = 'String for integer switch';
   argsInvalid($test, '--RequiredString=abc', '--RequiredInteger=asdf', '--RequiredFloat=456.78');
   $self->argOK('RequiredString', $test);
   $self->argWrongType('RequiredInteger', $test);
   $self->argOK('RequiredFloat', $test);

   $test = 'Float for integer switch';
   argsInvalid($test, '--RequiredString=abc', '--RequiredInteger=123.45', '--RequiredFloat=456.78');
   $self->argOK('RequiredString', $test);
   $self->argWrongType('RequiredInteger', $test);
   $self->argOK('RequiredFloat', $test);

   $test = 'String for float switch';
   argsInvalid($test, '--RequiredString=abc', '--RequiredInteger=123', '--RequiredFloat=asdf');
   $self->argOK('RequiredString', $test);
   $self->argOK('RequiredInteger', $test);
   $self->argWrongType('RequiredFloat', $test);

   $test = 'Embedded spaces for float switch';
   argsInvalid($test, '--RequiredString=abc', '--RequiredInteger=123', '--RequiredFloat="12 34"');
   $self->argOK('RequiredString', $test);
   $self->argOK('RequiredInteger', $test);
   $self->argWrongType('RequiredFloat', $test);
}

1
