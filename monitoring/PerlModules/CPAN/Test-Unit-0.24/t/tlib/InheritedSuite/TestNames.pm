package InheritedSuite::TestNames;

# This class is probably overkill :-)

use strict;

use base 'Test::Unit::TestCase';

use InheritedSuite::Simple;
use InheritedSuite::OverrideNew;
use InheritedSuite::OverrideNewName;

sub test_names {
  my $self = shift;

  my $simple = InheritedSuite::Simple->new();
  $self->assert_str_equals('Simple inherited suite', $simple->name());

  my $override_new = InheritedSuite::OverrideNew->new();
  $self->assert_str_equals('Inherited suite overriding new()',
                           $override_new->name());

  my $override_new_name = InheritedSuite::OverrideNewName->new();
  $self->assert_str_equals('Inherited suite overriding new() and name()',
                           $override_new_name->name());
}

1;
