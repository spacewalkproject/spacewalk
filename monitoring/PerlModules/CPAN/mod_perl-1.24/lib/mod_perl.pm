package mod_perl;
use 5.003_97;
use strict;
use DynaLoader ();

BEGIN {
    $mod_perl::VERSION = "1.24";
}

sub boot {
    my($class, $version) = @_;
    no strict 'refs';
    *{$class.'::dl_load_flags'} = DynaLoader->can('dl_load_flags');
    if ($ENV{MOD_PERL}) {
        (defined &{$class.'::bootstrap'} ?
         \&{$class.'::bootstrap'} :
         \&DynaLoader::bootstrap)->
             ($class, $version);
    }
}

sub hook {
    my $hook = shift;
    return 1 if $hook =~ /^PerlHandler$/;

    (my $try = $hook) =~ s/^Perl//;
    $try =~ s/Handler$//;
    return Apache::perl_hook($try) > 0;
}

sub import {
    my $class = shift;

    return unless @_;

    if($_[0] =~ /^\d/) {
	$class->UNIVERSAL::VERSION(shift);
    }
    return unless $ENV{MOD_PERL};

    for my $hook (@_) {
	require Apache;
	my $enabled = hook($hook); 
	next if $enabled > 0;
	if($enabled < 0) {
	    die "unknown mod_perl option `$hook'\n";
	}
	else {
	    (my $flag = $hook) =~ s/([A-Z])/_$1/g;
	    $flag = uc $flag;
	    die "`$hook' not enabled, rebuild mod_perl with PERL$flag=1\n";
	}
    }
}

1;

__END__
