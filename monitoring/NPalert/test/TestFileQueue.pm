package test::TestFileQueue;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::FileQueue;
use File::Basename;
use Storable;
use NOCpulse::Notif::Alert;
use NOCpulse::Log::Logger;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

my $MODULE = 'NOCpulse::Notif::FileQueue';

my $directory = "/tmp/$$";

my $alert = NOCpulse::Notif::Alert->new(
  'checkCommand' => '27',
  'clusterDesc' => 'NPops-dev',
  'clusterId' => '10702',
  'commandLongName' => 'Load',
  'customerId' => '30',
  'groupId' => '13254',
  'groupName' => 'Karen-3-group',
  'hostAddress' => '172.16.0.106',
  'hostName' => 'Velma.stage',
  'hostProbeId' => '22775',
  'mac' => '00:D0:B7:A9:C7:DE',
  'osName' => 'Linux System',
  'physicalLocationName' => 'for testing - do not delete me',
  'probeDescription' => 'Unix: Load',
  'probeGroupName' => 'unix',
  'probeId' => '22776',
  'probeType' => 'ServiceProbe',
  'snmp' => '',
  'snmpPort' => '',
  'state' => 'UNKNOWN',
  'subject' => '',
  'time' => '1024643798',
  'type' => 'service');

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
        
}

############
sub set_up {
############
  my $self = shift;
  # This method is called before each test.

  $self->{'queue'} = $MODULE->new('directory'  => $directory,
                                  'item_class' => 'NOCpulse::Notif::Alert'); 

  mkdir ($directory,0777);
  foreach (qw (one two three)) {
    $alert->message("$_ test message");
    $alert->store("$directory/$_");    
  }
}

###############
sub tear_down {
###############
  my $self = shift;
  # Run after each test

  `rm -rf $directory`;
}

# INSERT INTERESTING TESTS HERE

 ####################
 sub test__filelist {
 ####################
   my $self = shift;
 
   my @files=$self->{'queue'}->_filelist();
   @files=sort(@files);
  
   $Log->dump(1,"\n\n(#1) files are ",@files,"\n\n");
 
   $self->assert(grep {/one/}   @files,'(1) one');
   $self->assert(grep {/two/}   @files,'(1) two');
   $self->assert(grep {/three/} @files,'(1) three');
    
   $self->{'queue'}->dequeue();
 
   @files=$self->{'queue'}->_filelist();
   @files=sort(@files);
 
   $Log->dump(1,"\n\n(#2) files are ",@files,"\n\n");
 
   $self->assert(!(grep {/one/}   @files),'(2) not one');
   $self->assert(  grep {/two/}   @files, '(2) two');
   $self->assert(  grep {/three/} @files, '(2) three');
   $self->{'queue'}->dequeue();
   $self->{'queue'}->dequeue();
 
   $Log->dump(1,"\n\n(#3) files are ",@files,"\n\n");
                                                     
   @files=$self->{'queue'}->_filelist();
   $self->assert(!@files,'(3) files is empty');
 
  foreach (qw (four five six)) {
    
    $alert->message("$_ test message");
    $alert->store("$directory/$_");    
  }

  @files=$self->{'queue'}->_filelist();
  @files=sort(@files);

  $Log->dump(1,"\n\n(#4) files are ",@files,"\n\n");

  $self->assert(!(grep {/two/}   @files),'(4) not two');
  $self->assert(!(grep {/three/} @files),'(4) not three');
  $self->assert(  grep {/four/} @files,  '(4) four');
  $self->assert(  grep {/five/} @files,  '(4) five');
  $self->assert(  grep {/six/}  @files,  '(4) six');
}

 ###############
 sub test_peek {
 ###############
   my $self = shift;

   my @files=qw(one two three);
   # Examine the first one

   my $alert=$self->{'queue'}->peek();
   $Log->dump(1,"alert is ", $alert, "\n");
   $self->assert(qr /Alert/,$alert);

   $Log->log(1,"checkCommand is >>", $alert->checkCommand(), "<<\n");
   $self->assert($alert->checkCommand() == 27 ,'checkCommand');

   $Log->log(1,"groupId is >>", $alert->groupId(), "<<\n");
   $self->assert($alert->groupId() == 13254 ,'groupId');

   $Log->log(1,"type is >>", $alert->type(), "<<\n");
   $self->assert($alert->type() eq 'service','type');

   $alert->message =~ /^(\w*)/;
   my $first=$1;
   $self->assert(-e "$directory/$first.inp","(1) first.inp: $first");

    # Examine the second one
 
    $self->{'queue'}->dequeue();  
 
    $alert=$self->{'queue'}->peek();
    $Log->dump(1,"alert is ", $alert, "\n");
    $self->assert(qr /Alert/,$alert);
 
    $alert->message =~ /^(\w*)/;
    my $second=$1;
    $self->assert(-e "$directory/$second.inp","(2) second.inp");
    $self->assert($first ne $second,"(2) first ne second");
 
    # Examine the third one
 
    $self->{'queue'}->dequeue();  
 
    $alert=$self->{'queue'}->peek();
    $Log->dump(1,"alert is ", $alert, "\n");
    $self->assert(qr /Alert/,$alert);
 
    $alert->message =~ /^(\w*)/;
    my $third=$1;
    $self->assert(-e "$directory/$third.inp","(3) third.inp: $third");
    $self->assert($first ne $third, "(3) first ne third");
    $self->assert($second ne $third,"(3) second ne third");
 
    # Examine the queue after all are gone
 
    $self->{'queue'}->dequeue();  
 
    $alert=$self->{'queue'}->peek();
    $self->assert(!defined($alert),'(4) undefined alert');
  }
 
 ##################
 sub test_dequeue {
 ##################
   my $self = shift;
 
   my $alert=$self->{'queue'}->dequeue();
   $self->assert(qr /Alert/,$alert);
 
   $alert->message =~ /^(\w*)/;
   my $first=$1;
   $self->assert(!( -e "$directory/$first" ),    "(1) $first is deleted");
   $self->assert(!( -e "$directory/$first.inp" ),"(1) $first.inp is deleted");
 
   $alert=$self->{'queue'}->dequeue();
   $self->assert(qr /Alert/,$alert);
 
   $alert->message =~ /^(\w*)/;
   my $second=$1;
   $self->assert(!( -e "$directory/$second" ),    "(2) $second is deleted");
   $self->assert(!( -e "$directory/$second.inp" ),"(2) $second.inp is deleted");
 
   $alert=$self->{'queue'}->dequeue();
   $self->assert(qr /Alert/,$alert);
 
   $alert->message =~ /^(\w*)/;
   my $third=$1;
   $self->assert(!( -e "$directory/$third" ),    "(3) $third is deleted");
   $self->assert(!( -e "$directory/$third.inp" ),"(3) $third.inp is deleted");
 
   $alert=$self->{'queue'}->dequeue();
   $self->assert(!defined($alert),'(4) undefined alert');
 
   my @files=glob("$directory/*");
   $self->assert(!@files,'(4) empty directory');
  }

###############
sub test_skip {
###############
  my $self=shift;

  my $queue=$self->{'queue'};
  $queue->skip;

  my $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^two/,  "1 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^three/,"2 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^one/,  "3 " . $alert->message);
}

#################
sub test_skip_2 {
#################
  my $self=shift;

  my $queue=$self->{'queue'};
  $queue->peek;
  $queue->skip;

  my $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^two/,  "1 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^three/,"2 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^one/,  "3 " . $alert->message);
}

#################
sub test_skip_3 {
#################
  my $self=shift;

  my $queue=$self->{'queue'};
  $queue->skip;
  $queue->skip;
  $queue->skip;

  my $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^one/,  "1 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^two/,  "2 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^three/,"3 " . $alert->message);
}

#################
sub test_skip_4 {
#################
  my $self=shift;

  my $queue=$self->{'queue'};
  $queue->peek;
  $queue->skip;
  $queue->peek;
  $queue->skip;
  $queue->peek;
  $queue->skip;

  my $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^one/,  "1 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^two/,  "2 " . $alert->message);
  $alert=$queue->dequeue;
  $self->assert($alert->message =~ /^three/,"3 " . $alert->message);
}

#################
sub test_skip_5 {
#################
  my $self=shift;

  my $queue=$self->{'queue'};
  $queue->dequeue;
  $queue->dequeue;
  $queue->dequeue;
  $queue->skip;  #empty queue

  my $alert=$queue->dequeue;

  $self->assert(!defined($alert),"test_skip_5");
}

#######################
sub test_current_file {
#######################
  my $self=shift;
  my $queue=$self->{'queue'};

  $queue->_current_file('blah');
  $self->assert($queue->current_file eq 'blah');
}

1;
