# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.1.1.1 2001-05-31 01:31:47 dfaraldo Exp $

require 5.002;
use ExtUtils::MakeMaker;
use Config qw(%Config);

#--- MY package

sub MY::libscan
{
 my($self,$path) = @_;

 return '' 
	if($path =~ m:/(RCS|CVS|SCCS)/: ||
	   $path =~ m:[~%]$: ||
	   $path =~ m:\.(orig|rej)$:
	  );
 
 $path;
}

#--- Installation check

sub chk_version
{
 my($pkg,$wanted,$msg) = @_;

 $| = 1;
 print "Checking for $pkg...";

 eval { my $p; ($p = $pkg . ".pm") =~ s#::#/#g; require $p; };

 my $vstr = ${"${pkg}::VERSION"} ? "found v" . ${"${pkg}::VERSION"}
				 : "not found";
 my $vnum = ${"${pkg}::VERSION"} || 0;

 print $vnum >= $wanted ? "ok\n" : " " . $vstr . "\n";

 $vnum >= $wanted;
}

#--- Check for Socket

chk_version(Socket => '1.30') or
    warn  "\n"
	. "*** For IO::Socket to work you require version 1.30, or later, of\n"
	. "    Socket.pm from CPAN/modules/by-module/Socket/Socket-x.x.tar.gz\n\n";

#--- Attempt to find <poll.h>

my $define = "";

my @inc = split(/\s+/, join(" ",$Config{'usrinc'},$Config{'incpth'},$Config{'locincpth'}));
foreach $path (@inc) {
    if(-f $path . "/poll.h") {
	$define .= "-DI_POLL ";
	last;
    }
}

#--- Write the Makefile

WriteMakefile(
	VERSION_FROM	=> "IO.pm",
	NAME      	=> "IO",
	OBJECT		=> '$(O_FILES)', 
	DEFINE		=> $define,
	'dist'    	=> {COMPRESS => 'gzip -9f',
			    SUFFIX   => 'gz', 
			    DIST_DEFAULT => 'tardist',
			   },
 
	'clean'   	=> {FILES => join(" ",
					map { "$_ */$_ */*/$_" }
					qw(*% *.html *.b[ac]k *.old *.orig))
			   },
	'macro'		=> { INSTALLDIRS => 'perl' },
);
