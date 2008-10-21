package ProbeGenerator;
use strict;
use NOCpulse::Object;
use NOCpulse::DBMObjectRepository;
use NOCpulse::PlugFrame::Plugin;
use NOCpulse::CommandLineApplicationComponent
use MemoryPlugin;
use vars qw(@ISA);
@ISA=qw(NOCpulse::Object);

DBMObjectRepository->CacheHandles(1);

sub instVarDefinitions {
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('probeRecord');
	$self->addInstVar('probe');
}

sub initialize {
	my ($self,$probeRecord) = @_;
        $self->set_probeRecord($probeRecord);
	return $self;
}

sub createProbe {
   my ($self) = @_;
   #print $self->get_probeRecord->printString;
   my $recid = $self->get_probeRecord->get_RECID;
   my $args = $self->get_probeRecord->get_parsedCommandLine;
   my @cmdline = ();
   while (my ($param, $value) = each %$args) {
      push(@cmdline, '--'.$param.'='.$value);
   }
   push(@cmdline, "--saveid=$recid", '--xmlUsage');
   @ARGV = @cmdline;
   #print "\nARGV=".join(' ',@ARGV)."\n";
   my $result = MemoryPlugin->newInitialized($self->get_probeRecord);
   $self->set_probe($result);
   NOCpulse::CommandLineApplicationComponent::FreeAllInstances;
   return $result;
}

1
