package Blah;

use Class::MethodMaker
  new => 'new';


###########################
sub sort_by_numeric_value {
###########################
  my $self = shift;
  my $ary  = shift;

  return sort {$ary->{$a} <=> $ary->{$b}} keys %$ary;
}

1;
