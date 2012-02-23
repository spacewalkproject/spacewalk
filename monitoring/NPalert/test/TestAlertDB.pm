package test::TestAlertDB;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::AlertDB;
use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::AlertDB';

$| = 1;

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

  $self->{'blah'}=$MODULE->new();
}

###############
sub tear_down {
###############
  my $self = shift;
  $self->{'blah'}->disconnect;
}

# INSERT INTERESTING TESTS HERE

##################
sub test_general {
##################
  my $self=shift;
  $self->{'blah'}->dbprepare('test','select 29 as x from dual');
  my ($err,$arrayref)=$self->{'blah'}->dbexecute('test');
  if ($err) {
    $Log->log(1,"err: $arrayref\n");
    $self->assert(!$err);
  } else {
    $Log->dump(1,"\narray: ",$arrayref,"\n");
    my $value=shift(@$arrayref);
    $value=shift(@$value);
    $Log->dump(1,"\nvalue: ",$value,"\n");
    $self->assert($value == 29);
  }
}

#######################
sub test_redirect_seq {
#######################
  my $self=shift;
  my ($one,$two);
  my ($err,$arrayref)=$self->{'blah'}->dbexecute('select_next_redirect_recid');
  my ($err2,$arrayref2)=$self->{'blah'}->dbexecute('select_next_redirect_recid');
  if ($err) {
    $Log->log(1,"err: $arrayref\n");
    $self->assert(!$err,'err');
  } else {
    $Log->dump(1,"\narray: ",$arrayref,"\n");
    my $value=shift(@$arrayref);
    $one=shift(@$value);
    $Log->dump(1,"\nvalue: ",$one,"\n");
  }
  if ($err2) {
    $Log->log(1,"err2: $arrayref2\n");
    $self->assert(!$err2,'err2');
  } else {
    $Log->dump(1,"\narray: ",$arrayref2,"\n");
    my $value=shift(@$arrayref2);
    $two=shift(@$value);
    $Log->dump(1,"\nvalue: ",$two,"\n");
  }
  $self->assert($two == $one + 1,"sequence");
}

####################
sub test_redirects {
####################
  my $self=shift;
  my ($err,$arrayref)=$self->{'blah'}->dbexecute('select_next_redirect_recid');
  my $value=shift(@$arrayref);
  my $one=shift(@$value);

  ($err)=$self->{'blah'}->dbexecute('create_redirect',$one,30,454,'METOO','test redirects','test program','01-01-2003 00:00:00','01-01-2003 00:00:01','testpgm');

  $self->assert(!$err,'create_redirect');

  ($err)=$self->{'blah'}->dbexecute('create_redirect_criterion',$one,'PROBE_ID',1);
  $self->assert(!$err,'create_redirection');

  ($err)=$self->{'blah'}->dbexecute('create_redirect_email_target',$one,'nobody@nocpulse.com');
  $self->assert(!$err,'create_redirect_email_target');

  ($err)=$self->{'blah'}->dbexecute('delete_redirect_email_targets',$one);
  $self->assert(!$err,"delete_redirect_email_targets $err");

  ($err)=$self->{'blah'}->dbexecute('delete_redirect_criteria',$one);
  $self->assert(!$err,'delete_redirect_criteria');

  ($err)=$self->{'blah'}->dbexecute('delete_redirect',$one);
  $self->assert(!$err,'delete_redirect');
}

sub test_connected {
  #See test_connect
}

sub test_disconnect {
  #See test_connect
}

sub test_dbprepare {
  #See test_connect
}

##################
sub test_connect {
##################
  my $self = shift;
  my $db = $self->{'blah'};

  $db->connect;

  eval {
    $db->dbprepare("select * from dual");
  };

  $self->assert(!$@,"connect");
  $self->assert($db->connected, "connected");
  
  $db->disconnect;
  $self->assert(!$db->connected, "not connected");
  
}

sub test_init_statements {
  my $self = shift;
  my $db = $self->{'blah'};
  $db->connect;

  my @values=$db->statements_values;
  my $size=scalar(@values);

  $self->assert($size > 0, "test_init_statements");
}

1;
