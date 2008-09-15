package Apache::Options;
use Apache::Constants ();
@ISA = qw(Apache::Constants);
*EXPORT = $Apache::Constants::EXPORT_TAGS{options};
$VERSION = '1.61';

1;

__END__

=head1 NAME

Apache::Options - OPT_* defines from httpd_core.h

=head1 SYNOPSIS

    use Apache::Options;

=head1 DESCRIPTION

The B<Apache::Options> module will export the following bitmask
constants:

   OPT_NONE
   OPT_INDEXES
   OPT_INCLUDES 
   OPT_SYMLINKS
   OPT_EXECCGI
   OPT_UNSET
   OPT_INCNOEXEC
   OPT_SYM_OWNER
   OPT_MULTI
   OPT_ALL

These constants can be used to check the return value from
Apache->request->allow_options() method.

This module is simply a stub which imports from L<Apache::Constants>,
just as if you had said C<use Apache::Constants ':options';>.

=head1 SEE ALSO

L<Apache>, L<Apache::Constants>

=cut
