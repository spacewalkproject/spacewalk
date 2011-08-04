package ProbeCatalog;

use strict;

use NOCpulse::Config;
use Storable;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;

    my $config = NOCpulse::Config->new();
    $self->{probe_records} = Storable::retrieve($config->get('netsaint', 'probeRecordDatabase'));

    return $self;
}

sub all_probes {
    my $self = shift;

    my @probes;
    my $probeHashRef = $self->{probe_records};
    while(my $probe = each %$probeHashRef) {
	push @probes, $probe;
    }
    return @probes;
}

sub describe {
    my ($self, $probe_id, $includeCommandLine, $dump) = @_;

    my $probeHashRef = $self->{probe_records}->{$probe_id};
    my $result;
    if ($probe_id) {
	$result = $probeHashRef->{RECID}.' '.$probeHashRef->{PROBE_TYPE};;
	if ($probeHashRef->{HOSTNAME}) {
	    $result .= ' on '.$probeHashRef->{HOSTNAME}.' ('.$probeHashRef->{HOSTADDRESS}.')';
	} else {
	    $result .= ' on '.$probeHashRef->{HOSTADDRESS};
	}
	$result .= ': '.$probeHashRef->{DESCRIPTION};

	if ($includeCommandLine) {
	    my $paramHashRef = $probeHashRef->{parsedCommandLine};
	    $result .= "\n      Run as: ".$paramHashRef->{probe}.'.pm ';
	    while (my ($param, $value) = each %$paramHashRef) {
		$result.= "--$param=$value " unless $param eq 'probe';
	    }
	}
	if ($dump) {
	    $result .= "\n".Dumper($probeHashRef);
	}
    } else {
	$result = "Cannot find a probe_id to lookup \n";
    }

    return $result;

}

1;

__END__

=head1 NAME

ProbeCatalog - Fetch probe instances from the probe database for information purposes 

=head1 SYNOPSIS

  my $catalog = new ProbeCatalog();
  print $catalog->all_probes();
  print $catalog->describe(1234);

=head1 DESCRIPTION

  Fetches the probe database and is used to describe probes and their parameters. Currently used only by the catalog and status scripts.

=head1 AUTHOR

  Nick Hansen <nhansen@redhat.com>

