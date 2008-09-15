package Globby;

# More-portable but limited glob().  It does what we need.

use Exporter;
use vars qw(@ISA @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(globby);

sub globby {
    my $globpath = shift;    # full glob
    my %r = ('.'=>'\.',
	     '*'=>'.*',
	     '?'=>'.');

    # Get directory and regexp:
    my ($dir, $glob) = ($globpath =~ m{^(.*?)/?([^/]+\Z)});
    defined($dir) or $dir = '';
    my $re = $glob; $re =~ s{([\.\*\?])}{$r{$1}}g;

    # Get files which match pattern:
    my @f;
    if (opendir DIR, $dir) {
	@f = grep /^$re\Z/, sort(readdir(DIR));
	closedir DIR;
    }

    # Return as full paths:
    map { ($dir ne '') ? "$dir/$_" : $_}  @f;
}
1;
