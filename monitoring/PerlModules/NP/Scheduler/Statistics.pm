package NOCpulse::Scheduler::Statistics;

use strict;
use NOCpulse::Scheduler::Event;


# Per-probe latency
my %probeLatency;

my $debug;


sub setDebug {
   $debug = shift;
}

sub calculateLatency {
   my ($event, $now) = @_;

   # Calculate latency. The first time through this may be
   # meaningless, because it is an offset from the last config push,
   # so set it to zero.
   if (exists $probeLatency{$event->id}) {
      $probeLatency{$event->id} = $now - $event->time_to_execute;
   } else {
      $probeLatency{$event->id} = 0;
   }
   if (defined($debug)) {
      $debug->dprint(4, "Calculate latency for ", $event->id, " as ",
		     (scalar localtime($now)), ' - ',
		     (scalar localtime($event->time_to_execute)),
		     ' = ', $probeLatency{$event->id}, "\n");
   }
}

sub latency {
   my ($probeId) = @_;
   if (exists $probeLatency{$probeId}) {
      return $probeLatency{$probeId};
   }
   return undef;
}

sub averageLatency {
   my @latencies = values %probeLatency;
   my $total = 0;
   foreach my $latency (@latencies) {
      $total += $latency;
   }
   my $numLatencies = (scalar @latencies);
   if ($numLatencies > 0) {
      return $total / $numLatencies;
   } else {
      return -1;
   }
}

1;
