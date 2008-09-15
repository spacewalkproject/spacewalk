package Apache::TestDirectives;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

BEGIN {
    use lib qw{../../lib};
}

use strict;
use Apache::src ();
use Apache::ExtUtils qw(command_table);

my $class = __PACKAGE__;

my @directives = (
   [Port => "A TCP port number"], #we'll decline this one
   [TestCmd => "Two TestCmd args"],
   [AnotherCmd => "Stuff for another command"],
   [CmdIterate => "No limit here"],
   ["<Container" => "whatever"],
   ["</Container>" => "end whatever"],
   {
       name => "YAC",
       func => "another_cmd",
       cmd_data => "info for YAC",
       errmsg => "Yet another comand",
       args_how => "TAKE2",
       req_override => "RSRC_CONF",
   },
);

my $proto_perl2c = Apache::ExtUtils->proto_perl2c;

while(my($pp,$cp) = each %$proto_perl2c) {
    next unless $pp;
    push @directives, [$cp, "Test for $cp"];
}

command_table \@directives;

WriteMakefile(
    'NAME'	=> $class,
    'VERSION_FROM' => 'TestDirectives.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> Apache::src->new->inc,
);
