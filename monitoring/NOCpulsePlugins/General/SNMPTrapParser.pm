package General::SNMPTrapParser;

use strict;

use Error qw(:try);

use NOCpulse::Config;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Result;
use NOCpulse::Utils::XML;

use ProbeMessageCatalog;

use constant ITEM_NAME => 'snmp_trap';

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

my $MAX_OUTPUT_SIZE = 1400;     # max length of status string

# Formatted text
my $footerfmt  = "%d other matching traps received but not displayed. " .
  "Consult User Guide for suggestions on optimizing this check.";
my $verbosefmt = "%s trap: %s at %s\n";
my $summaryfmt = "%d %s traps: %s, last at %s:\n";
my $compactfmt = "%d %s traps: %s, last at %s\n";
my $varbindfmt = "\t%s => %s\n";

my %statuses = ('crit' => NOCpulse::Probe::Result::CRITICAL,
		'warn' => NOCpulse::Probe::Result::WARNING);

my %labels   = ('crit' => 'Critical',
		'warn' => 'Warning');

my @MONTHS   = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);


######################################################################

sub run {
    my %args = @_;
    
    my $result = $args{result};
    my %params = %{$args{params}};
    
    my $config = NOCpulse::Config->new();
    my $traps;
    my $overflows = 0;
    
    try {
        
        my $recid   = $result->probe_record->recid;
        my $trapdir = $config->get('trapReceiver', 'trapdir');
        my $mbox    = "$trapdir/$recid";
        
        # Were there regex errors?
        if (-f "$mbox.ERROR") {
            
            $Log->log_method(1, "run", "Errors found -- bailing out\n");
            
            # Yup -- just bail out.
            local * ERR;
            open(ERR, '<', "$mbox.ERROR");
            my $errors = join('', <ERR>);
            close(ERR);
            
            # ... but not before deleting any working files
            unlink("$mbox.WORKING", "$mbox.OVER", $mbox);
            
            $Log->log_method(1, "run", "\tErrors:  $errors\n");
            throw NOCpulse::Probe::DataSource::ConfigError($errors);
        }

        if (-f $mbox) {
            # We (may) have traps.
            $Log->log_method(2, "run", "$mbox file exists\n");
            ($traps, $overflows) = load_traps($mbox);
        }

        if (defined($traps)) {

            # We really do have traps.
            $Log->log_method(2, "run", "Got $traps\n");
            my($status, $output) = process_traps($traps, $overflows);
            set_result($result, $status, $output);

        } else {
        
            # No traps this period.
            $Log->log_method(2, "run", "No traps\n");
            set_result($result, $result->OK, "No traps received since last run");
        
        }

    } catch NOCpulse::Probe::DataSource::ConfigError with {        

        my $err = shift;
        set_result($result, $result->UNKNOWN, $err->message);

    };
    
}

sub set_result {
    my ($result, $status, $message) = @_;
    $result->item_status($status, name => ITEM_NAME, message => $message);
}

sub load_traps {
    my $mbox = shift;

    # Smoke the leftover trap file(s), if any
    unlink("$mbox.WORKING");
            
    # Rename the mailbox so we don't collide with incoming traps
    rename($mbox, "$mbox.WORKING") 
      or throw NOCpulse::Probe::InternalError("Cannot rename $mbox to $mbox.WORKING: $!");
            
    # Suck up the traps
    local * TRAPS;
    open(TRAPS, '<', "$mbox.WORKING")
      or throw NOCpulse::Probe::InternalError("Cannot open $mbox.WORKING: $!");
    
    my $xml = "<perldata>\n<array>\n";
    my $i = 0;
    while (<TRAPS>) {
        if (/<perldata>/) {
            $xml .= "<item key=\"$i\">\n";
            $i++;
        } elsif (/<\/perldata>/) {
            $xml .= "</item>\n";
        } else {
            $xml .= $_;
        }
    }
    $xml .= "</array>\n</perldata>\n";
    close(TRAPS);

    $Log->log_method(4, 'load_traps', "Trap XML:\n$xml\n");

    my $traps = NOCpulse::Utils::XML->unserialize($xml);

    my $overflows = 0;

    # Were there overflows?
    if (-f "$mbox.OVER") {
        $overflows = (stat("$mbox.OVER"))[7];
        unlink("$mbox.OVER");
    }
            
    # Clean up
    unlink("$mbox.WORKING");

    return ($traps, $overflows);
}

sub process_traps {
    my($traps, $overflows) = @_;
    my($status, $outputstring, $footer, $trap, $oid);
    
    # We need to get the output string below $MAX_OUTPUT_SIZE.
    # To do that, we use one of four formats, each more
    # terse than the last.
    
    # No matter what format we use, we may also need a count of 
    # traps dropped because the mailbox was full:
    $footer = sprintf($footerfmt, $overflows) if ($overflows);
    
    # Potential formats are:
    #   1) Full info for all traps, including varbinds.
    
    my $toobig;
    foreach $trap (sort trapsort @$traps) {
        # Traps are sorted first by level, so first trap should have 
        # correct probe status.
        $status = $statuses{$trap->{'level'}} unless ($status);
        
        my $oid = $trap->{'varbinds'}->{'snmpTrapOID.0'} || $trap->{'oid'};
        $outputstring .= sprintf($verbosefmt, $labels{$trap->{'level'}}, $oid,
                                 &timestamp($trap->{'received'}));
        
        my $var;
        foreach $var (sort keys %{$trap->{'varbinds'}}) {
            next if ($var eq 'snmpTrapOID.0');
            $outputstring .= sprintf($varbindfmt, $var, $trap->{'varbinds'}->{$var});
        }
        
        if (length($outputstring) + length($footer) > $MAX_OUTPUT_SIZE) {
            $toobig = 1;
            last;
        }
    }
    
    
    if ($toobig) {
        
        #   2) A count of occurrences of each unique trap OID plus 
        #      varbinds for the last occurrence of each.
        
        $toobig = 0;
        my(%last, %count, @oids);
        foreach $trap (sort trapsort @$traps) {
            
            my $oid = $trap->{'varbinds'}->{'snmpTrapOID.0'} || $trap->{'oid'};
            $last{$oid} = $trap;
            push(@oids, $oid) unless ($count{$oid});
            $count{$oid}++;
            
        }
        
        $outputstring = '';
        foreach $oid (@oids) {
            
            $outputstring .= sprintf($summaryfmt, $count{$oid},
                                     $labels{$last{$oid}->{'level'}},
                                     $oid, &timestamp($last{$oid}->{'received'}));
            
            
            my $var;
            foreach $var (sort keys %{$last{$oid}->{'varbinds'}}) {
                next if ($var eq 'snmpTrapOID.0');
                $outputstring .= sprintf($varbindfmt, $var, $last{$oid}->{'varbinds'}->{$var});
            }
            
            if (length($outputstring)  + length($footer) > $MAX_OUTPUT_SIZE) {
                $toobig = 1;
                last;
            }
        }
        
        if ($toobig) {
            $outputstring = '';
            #   3) A count of occurrences of each unique trap OID, or
            #   4) 3 truncated, with a count of omitted OIDs
            
            foreach $oid (@oids) {
                
                my $str = sprintf($compactfmt, $count{$oid},
                                  $labels{$last{$oid}->{'level'}},
                                  $oid, &timestamp($last{$oid}->{'received'}));
                if (length($outputstring) + length($footer) + length($str) < $MAX_OUTPUT_SIZE) {
                    
                    $outputstring .= $str;

	} else {

	  $overflows++;
	  $footer = sprintf($footerfmt, $overflows);

	}
      }
    }
  }

  $outputstring .= $footer;

  return($status, $outputstring);

}

sub trapsort {
    $a->{'level'}    cmp $b->{'level'}     or
    $a->{'received'} cmp $b->{'received'}  or
    $a->{'oid'}      cmp $b->{'oid'};
}


sub timestamp {
    my $time = shift || time;
    my($sec,$min,$hour,$mday,$mon) = gmtime($time);
    return sprintf("%s %2d %2d:%02d:%02d GMT", 
                   $MONTHS[$mon], $mday, $hour, $min, $sec);
}

1;

