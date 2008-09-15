package Apache::StatusPage;

use strict;

use HTML::Parser;
use HTML::TableExtract;
use ProbeMessageCatalog;
use NOCpulse::Log::Logger;
use Data::Dumper;

use Class::MethodMaker
  get_set =>
  [qw(
      parse_ok
      parse_error_msg
      extended_status
      uptime
      accesses
      reqs
      traffic
      traffic_units
      max_childmb
      max_slotmb
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, $uri, $status_page_html) = @_;
    my $msgcat  = ProbeMessageCatalog->instance();
    my @parsed_data;

    my $p = HTML::Parser->new(api_version => 3,
			      handlers => { text  => [\@parsed_data, "event,text"],
					    start => [\@parsed_data, "event,text"],
					    end   => [\@parsed_data, "event,text"],
				  });

    if (defined($status_page_html)) {
	$Log->log(4, 'Status Page HTML: ', $status_page_html, "END\n");
	if ($status_page_html =~ m/\<TITLE\>Apache Status\<\/TITLE\>/is) {
	    $p->parse($status_page_html);
	    $self-parse_ok(1);
	    if ($status_page_html =~ m/To obtain a full report with current status information you need to use the/) {
		$self->extended_status(0);
		$Log->log(2, 'ExtendedStatus not enabled', "\n");
	    } else {
		$self->extended_status(1);
		$Log->log(2, 'ExtendedStatus set to On', "\n");
	    }
	} else {
	    $self-parse_ok(0);
	    $self->parse_error_msg(sprintf($msgcat->apache('parse_error'), $uri));
	    return undef;
	}
    } else {
	$self-parse_ok(0);
	$self->parse_error_msg(sprintf($msgcat->apache('no_status_page'), $uri));
	return undef;
    }

    if (!$self->parse_ok) {
	for (my $i=0; $i<@parsed_data; $i++) {
	    chomp($parsed_data[$i]->[1]);
	    $parsed_data[$i]->[1] =~ s/^\n//;
	    $parsed_data[$i]->[1] =~ s/(.*)\n(.*)/$1 $2/;
	    if ($parsed_data[$i]->[1] =~ m/Server uptime:(.*)/s) {
		$self->uptime($parsed_data[$i]->[1]);
		$Log->log(2, 'Found uptime: ', $self->uptime, "\n");
	    }
	    if ($self->extended_status) {
		if ($parsed_data[$i]->[1] =~ m/Total accesses: (\d+)/) {
		    $self->accesses($1);
		    $Log->log(2, 'Found accesses: ', $self->accesses, "\n");
		    if ($parsed_data[$i]->[1] =~ /Total Traffic:(.*)/) {
			my @traffic = split(/ /, $1);
			for (my $item=0; $item<@traffic; $item++) {
			    if ($traffic[$item] =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/) {
				$self->traffic($traffic[$item]);
				$self->traffic_units($traffic[$item + 1]);
				$Log->log(2, 'Found traffic: ', $self->traffic, "\n");
				check_traffic_units($self);
				last;
			    }
			}
		    }
		} elsif ($parsed_data[$i]->[1] =~ m/(\d+) requests currently/s) {
		    $self->reqs($1);
		    $Log->log(2, 'Found requests: ', $self->reqs, "\n");
		}
		#find first table tag on the page and parse it using HTML::TableExtract to find columns of useful data
		if (lc($parsed_data[$i]->[1]) =~ /table/) {
		    parse_table($self, $status_page_html);
		    last;
		}
	    }
	}
    }
    return $self;
}

# Need to make sure all traffic data is returned in KB
sub check_traffic_units {
    my $self = shift;

    if (lc($self->traffic_units) eq 'gb') {
	$self->traffic($self->traffic * 1000000);
	$Log->log(2, 'Adjusted traffic from gb to kb ', $self->traffic, "\n");
    } elsif (lc($self->traffic_units) eq 'mb') {
	$self->traffic($self->traffic * 1000);
	$Log->log(2, 'Adjusted traffic from mb to kb ', $self->traffic, "\n");
    }

    return $self;
}

sub parse_table {
    my ($self, $status_page_html) = @_;
    # Suck the interesting columns of the table out of the page
    my @headers = qw(Srv PID Child Slot);
    my $te = HTML::TableExtract->new(headers => \@headers);
    $te->parse($status_page_html);
    # Show me the money -- find max_slot and max_child
    my ($max_child, $max_slot) = 0;
    foreach my $ts ($te->table_states) {
	foreach my $row ($ts->rows) {
	    map(chomp($_), @$row);
	    @$row[2] > $max_child ? $max_child = @$row[2] : $max_child;
	    @$row[3] > $max_slot ? $max_slot = @$row[3] : $max_slot;
	}
    }
    #funky regex is to validate that datapoint is a number (Perl Cookbook, recipe 2.1)
    if ($max_child =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/) {
	$self->max_childmb($max_child);
	$Log->log(2, "Found: childmb = ", $self->max_childmb, "\n");
    }
    if ($max_slot =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/) {
	$self->max_slotmb($max_slot);
	$Log->log(2, "Found: slotmb = ", $self->max_slotmb, "\n");
    }

    return $self;
}



1;
