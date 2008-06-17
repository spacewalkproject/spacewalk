# -*- perl -*-

use strict;
use Config;
use File::Basename qw(&basename &dirname);
use Cwd;

# This forces PL files to create target in same directory as PL file.
# This is so that make depend always knows where to find PL derivatives.
my $origdir = cwd;
chdir dirname($0);
my $script = basename($0, '.PL');
$script .= '.com' if $^O eq 'VMS';

unlink($script);
open OUT, ">$script" or die "open for writing $script: $!";

print OUT <<"!GROK!THIS!";
$Config{startperl}
    eval 'exec $Config{perlpath} -S \$0 \${1+"\$@"}'
	if \$running_under_some_shell;
!GROK!THIS!

# In the following, perl variables are not expanded during extraction.

print OUT <<'!NO!SUBS!';
#!perl -w

use strict;
use vars qw($VERSION $TEST_MODE);
$VERSION = 0.2;

use Getopt::Long;

use Pod::Find qw(pod_find simplify_name);

my %opt;

# compatibility hack for previous version(s) of pod2html
my %oldopt;

die unless(GetOptions(\%opt, qw(
  converter=s
  suffix=s
  filesuffix=s
  dir=s
  libpods=s
  navigation!
  localtoc!
  toc!
  idx!
  tocname=s
  idxname=s
  toctitle=s
  idxtitle=s
  ps!
  psdir=s
  psfont=s
  papersize=s
  inc!
  script!
  warnings!
  verbose!
  help|h
  version|V),
    'flush' => \$oldopt{flush},
    'htmlroot=s' => \$oldopt{htmlroot}, # can be ignored
    'index!' => \$oldopt{'index'},
    'infile=s' => \$oldopt{infile},
    'netscape!' => \$oldopt{netscape}, # ignore
    'outfile=s' => \$oldopt{outfile},
    'podpath=s' => \$oldopt{podpath}, # can be ignored
    'podroot=s' => \$oldopt{podroot},
    'recurse!' => \$oldopt{recurse}, # ignored now
    'title=s' => \$oldopt{title},
    'verbose!' => \$oldopt{verbose} # ignored
));

my %addopts = ();

if($oldopt{infile}) {
  @ARGV = ( $oldopt{infile} );
}

if($oldopt{outfile}) {
  $addopts{-outfile} = $oldopt{outfile};
}

if($oldopt{podroot}) {
  push(@ARGV, $oldopt{podroot});
}

# process libpods
if($opt{libpods}) {
  # replace single : with , (old style)
  $opt{libpods} =~ s/(?<!:):(?!:)/,/g;
}

if(defined $oldopt{'index'}) {
  $opt{localtoc} = $oldopt{'index'};
}

if(defined $oldopt{title}) {
  $addopts{-title} = $oldopt{title};
}

my $converter = $opt{converter} || 'Marek::Pod::HTML';
eval "use $converter qw(pod2html);";
die "Fatal: Cannot load convertor module '$converter':\n$@\n"
    if($@);

if($opt{help}) {
}
elsif($opt{version}) {
    print "$0 Version $VERSION\n";
}
else {

    my %pods = ();
    my @dirs = ();

    foreach(@ARGV) {
        if(-d) {
            push(@dirs,$_);
        }
        elsif(/[*?]/) {
            foreach (glob($_)) {
                if(-d) {
                    push(@dirs,$_);
                }
                else {
                    my $name = simplify_name($_);
                    $pods{$_} = $name;
                }
            }
        }
        else {
           my $name = simplify_name($_);
           $pods{$_} = $name;
       }
    }
    my %search;

    if(@dirs || $opt{inc} || $opt{script}) {
        warn "+++ Searching for POD documents\n";
        %search = pod_find({
            -inc => $opt{inc},
            -script => $opt{script},
            -verbose => $opt{verbose}
          }, @dirs)
    }

    map { $pods{$_} = $search{$_} } keys %search;

    # run as a filter
    # we have to save it temporarily because we need two passes
    my $tmp;
    unless(%pods) {
        my $self = $0;
        $self =~ s:^.*/::;
        $tmp = "/tmp/$self.$$";
        open(TEMP, ">$tmp") || die "Cannot write temp file: $!\n";
        while(<STDIN>) {
            print TEMP;
        }
        close(TEMP);
        $pods{$tmp} = 'stdin';
        $addopts{-filter} = 1;
        $opt{navigation} = 0 unless defined $opt{navigation};
    }

    warn "+++ Starting conversion\n";

    pod2html( {
        -converter => $converter,
        -suffix => $opt{suffix},
        -filesuffix => $opt{filesuffix},
        -dir => $opt{dir},
        -libpods => $opt{libpods},
        -navigation => $opt{navigation},
        -localtoc => $opt{localtoc},
        -toc => $opt{toc},
        -idx => $opt{idx},
        -tocname => $opt{tocname},
        -idxname => $opt{idxname},
        -toctitle => $opt{toctitle},
        -idxtitle => $opt{idxtitle},
        -ps => $opt{ps},
        -psdir => $opt{psdir},
        -psfont => $opt{psfont},
        -papersize => $opt{papersize},
        -warnings => $opt{warnings},
        %addopts
    }, { %pods });

    unlink $tmp if($tmp);
}

exit 0 unless($TEST_MODE);
1; # this is for the module test

__END__

=head1 NAME

pod2html - convert Perl POD documentation to HTML

=head1 SYNOPSIS

B<pod2html> S<[ B<-converter> I<module> ]>
S<[ B<-suffix> I<suffix> ]> S<[ B<-filesuffix> I<suffix> ]>
S<[ B<-dir> I<path> ]> S<[ B<-libpods> I<pod1,pod2,...> ]>
S<[ B<->(B<no>)B<navigation> ]> 
S<[ B<->(B<no>)B<localtoc> ]> 
S<[ B<->(B<no>)B<toc> ]> 
S<[ B<->(B<no>)B<idx> ]> 
S<[ B<->(B<no>)B<ps> ]> 
S<[ B<->(B<no>)B<inc> ]> 
S<[ B<->(B<no>)B<script> ]> 
S<[ B<->(B<no>)B<warnings> ]> 
S<[ B<->(B<no>)B<verbose> ]> 
S<[ B<-tocname> I<filename> ]> S<[ B<-idxname> I<filename> ]>
S<[ B<-toctitle> I<title> ]> S<[ B<-idxtitle> I<title> ]>
S<[ B<-psdir> I<path> ]> S<[ B<-psfont> I<font> ]>
S<[ B<-papersize> I<format> ]>
S<[ I<dir1> , I<dir2> , ... ]>
S<[ I<pod1> , I<pod2> , ... ]>

=head1 DESCRIPTION

B<pod2html> converts Perl POD documentation to HTML.

=head1 OPTIONS

=head1 AUTHOR

Marek Rouchal E<lt>marekr@cpan.org<gt>

=head1 SEE ALSO

L<Pod::HTML>,
L<HTML::Element>, L<Pod::Parser>, L<Pod::Checker>, L<HTML::Entities>

=cut

!NO!SUBS!

close OUT or die "Can't close $script: $!";
chmod 0755, $script or die "Can't reset permissions for $script: $!\n";
exec("$Config{'eunicefix'} $script") if $Config{'eunicefix'} ne ':';
chdir $origdir;
