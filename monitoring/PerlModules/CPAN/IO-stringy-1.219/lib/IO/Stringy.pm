package IO::Stringy;

use vars qw($VERSION);
$VERSION = substr q$Revision: 1.999 $, 10;

1;
__END__


=head1 NAME

IO-stringy - I/O on in-core objects like strings and arrays


=head1 SYNOPSIS

    IO::
    ::AtomicFile   adpO  Write a file which is updated atomically     ERYQ
    ::Lines        bdpO  I/O handle to read/write to array of lines   ERYQ
    ::Scalar       RdpO  I/O handle to read/write to a string         ERYQ
    ::ScalarArray  RdpO  I/O handle to read/write to array of scalars ERYQ
    ::Wrap         RdpO  Wrap old-style FHs in standard OO interface  ERYQ
    ::WrapTie      adpO  Tie your handles & retain full OO interface  ERYQ


=head1 DESCRIPTION

This toolkit primarily provides modules for performing both traditional 
and object-oriented i/o) on things I<other> than normal filehandles; 
in particular, L<IO::Scalar|IO::Scalar>, L<IO::ScalarArray|IO::ScalarArray>, 
and L<IO::Lines|IO::Lines>.

If you have access to tie(), these classes will make use of the
L<IO::WrapTie|IO::WrapTie> module to inherit a convenient new_tie() 
constructor.  It also exports a nice wraptie() function.

In the more-traditional IO::Handle front, we 
have L<IO::AtomicFile|IO::AtomicFile>
which may be used to painlessly create files which are updated
atomically.

And in the "this-may-prove-useful" corner, we have L<IO::Wrap|IO::Wrap>, 
whose exported wraphandle() function will clothe anything that's not
a blessed object in an IO::Handle-like wrapper... so you can just
use OO syntax and stop worrying about whether your function's caller
handed you a string, a globref, or a FileHandle.


=head1 INSTALLATION

Most of you already know the drill...

    perl Makefile.PL
    make test
    make install

For everyone else out there...
if you've never installed Perl code before, or you're trying to use
this in an environment where your sysadmin or ISP won't let you do
interesting things, B<relax:> since this module contains no binary 
extensions, you can cheat.  That means copying the directory tree
under my "./lib" directory into someplace where your script can "see" 
it.  For example, under Linux:

    cp -r IO-stringy-1.234/lib/* /path/to/my/perl/
    
Now, in your Perl code, do this:

    use lib "/path/to/my/perl";
    use IO::Scalar;                   ### or whatever

Ok, now you've been told.  At this point, anyone who whines about
not being given enough information gets an unflattering haiku 
written about them in the next change log.  I'll do it.  
Don't think I won't.



=head1 VERSION

$Id: Stringy.pm,v 1.999 2001-03-30 03:13:03 dparker Exp $



=head1 TO DO

=over 4

=item (2000/08/02)  Finalize $/ support

Graham Barr submitted this patch half a I<year> ago; 
Like a moron, I lost his message under a ton of others,
and only now have the experimental implementation done.

Will the sudden sensitivity to $/ hose anyone out there?
I'm worried, so you have to enable it explicitly.


=item (2000/09/28)  Separate read/write cursors?

Binkley sent me a very interesting variant of IO::Scalar which
maintains two separate cursors on the data, one for reading
and one for writing.  Quoth he:

    Isn't it the case that real operating system file descriptors 
    maintain an independent read and write file position (and 
    seek(2) resets them both)? 

He also pointed out some issues with his implementation:  

    For example, what does eof or tell return?  The read position or 
    the write position?  (I assumed read position was more important). 

Your opinions on this are most welcome.
(Me, I'm just squeamish that this will break some code
which depends on the existing behavior, and that attempts to
maintain backwards-compatibility will slow down the code.
But I'll give it a shot.) 

=back



=head1 CHANGE LOG 

=over 4

=item Version 1.219   (2001/02/23)

IO::Scalar objects can now be made sensitive to $/ .
Pains were taken to keep the fast code fast while adding this feature.
I<Cheers to Graham Barr for submitting his patch; 
jeers to me for losing his email for 6 months.>


=item Version 1.218   (2001/02/23)

IO::Scalar has a new sysseek() method.
I<Thanks again to Richard Jones.>

New "TO DO" section, because people who submit patches/ideas should 
at least know that they're in the system... and that I won't lose
their stuff.  Please read it.  

New entries in L<"AUTHOR">.  
Please read those too.



=item Version 1.216   (2000/09/28)

B<IO::Scalar and IO::ScalarArray now inherit from IO::Handle.>
I thought I'd remembered a problem with this ages ago, related to
the fact that these IO:: modules don't have "real" filehandles,
but the problem apparently isn't surfacing now.  
If you suddenly encounter Perl warnings during global destruction
(especially if you're using tied filehandles), then please let me know!
I<Thanks to B. K. Oxley (binkley) for this.>

B<Nasty bug fixed in IO::Scalar::write().>
Apparently, the offset and the number-of-bytes arguments were,
for all practical purposes, I<reversed.>  You were okay if
you did all your writing with print(), but boy was I<this> a stupid bug!  
I<Thanks to Richard Jones for finding this one.  
For you, Rich, a double-length haiku:>

       Newspaper headline
          typeset by dyslexic man
       loses urgency
        
       BABY EATS FISH is
          simply not equivalent   
       to FISH EATS BABY

B<New sysread and syswrite methods for IO::Scalar.>
I<Thanks again to Richard Jones for this.>


=item Version 1.215   (2000/09/05)

Added 'bool' overload to '""' overload, so object always evaluates 
to true.  (Whew.  Glad I caught this before it went to CPAN.)


=item Version 1.214   (2000/09/03)

Evaluating an IO::Scalar in a string context now yields
the underlying string.
I<Thanks to B. K. Oxley (binkley) for this.>


=item Version 1.213   (2000/08/16)

Minor documentation fixes.


=item Version 1.212   (2000/06/02)

Fixed IO::InnerFile incompatibility with Perl5.004.
I<Thanks to many folks for reporting this.>


=item Version 1.210   (2000/04/17)

Added flush() and other no-op methods.
I<Thanks to Doru Petrescu for suggesting this.>


=item Version 1.209   (2000/03/17)

Small bug fixes.


=item Version 1.208   (2000/03/14)

Incorporated a number of contributed patches and extensions,
mostly related to speed hacks, support for "offset", and
WRITE/CLOSE methods.
I<Thanks to Richard Jones, Doru Petrescu, and many others.>



=item Version 1.206   (1999/04/18)

Added creation of ./testout when Makefile.PL is run.


=item Version 1.205   (1999/01/15)

Verified for Perl5.005.


=item Version 1.202   (1998/04/18)

New IO::WrapTie and IO::AtomicFile added.


=item Version 1.110   

Added IO::WrapTie.


=item Version 1.107   

Added IO::Lines, and made some bug fixes to IO::ScalarArray. 
Also, added getc().


=item Version 1.105   

No real changes; just upgraded IO::Wrap to have a $VERSION string.

=back




=head1 AUTHOR

=over 4

=item Primary Maintainer 

Eryq (F<eryq@zeegee.com>).
President, ZeeGee Software Inc (F<http://www.zeegee.com>).

=item Unofficial Co-Authors

For all their bug reports and patch submissions, the following
are officially recognized:

     Richard Jones
     B. K. Oxley (binkley) 
     Doru Petrescu 


=back

Enjoy.  Yell if it breaks.


=cut








