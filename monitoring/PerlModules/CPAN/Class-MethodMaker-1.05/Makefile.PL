require 5.00307;

### Not present in 5.005
###use File::Spec::Functions qw( catfile );

use constant MOD_REQS =>
  [
  ];

use constant EXEC_REQS =>
  [
  ];

use constant NAME         => 'Class-MethodMaker';
###use constant VERSION_FROM => catfile (qw( lib Class MethodMaker.pm ));
use constant VERSION_FROM => 'lib/Class/MethodMaker.pm';
use constant AUTHOR       => 'Martyn J. Pearce fluffy@cpan.org';
use constant ABSTRACT     => 'a module for creating generic methods';

use make;
