package test::TestNotificationIni;

use strict;
use File::Basename;
use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::NotificationIni;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::NotificationIni';

my $file = "/tmp/$$." . basename($0);

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj  = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");

} ## end sub test_constructor

############
sub set_up {
############
  my $self = shift;

  # This method is called before each test.
  $self->{'blah'} = $MODULE->new();

}

###############
sub tear_down {
###############
  my $self = shift;
  if (-e $file) {
    unlink $file;
  }
}

# INSERT INTERESTING TESTS HERE

######################
sub test_create_file {
######################

  my ($self) = @_;

  my $arrayptr = [
                   { 'RECID' => 1, 'NAME' => 'Diego',     'TITLE' => 'Don' },
                   { 'RECID' => 2, 'NAME' => 'Alejandro', 'TITLE' => 'Don' },
                   { 'RECID' => 3, 'NAME' => 'Zorro',     'TITLE' => 'Senor' }
                 ];

  $self->{'blah'}->key_field('RECID');
  $self->{'blah'}->file_name($file);

  $self->{'blah'}->create_file($arrayptr, 'RECID', 'NAME', 'TITLE');

  local * FILE;
  open(FILE, '<', $file) || die;
  my @result_array = <FILE>;
  close(FILE) || die;

  my $expected_result = <<EOT;
[1]
recid=1
name=Diego
title=Don
[2]
recid=2
name=Alejandro
title=Don
[3]
recid=3
name=Zorro
title=Senor
EOT

  my $result = join('', @result_array);

  $expected_result =~ s/\s//g;
  $result          =~ s/\s//g;

  # print "expected_result:\n$expected_result\n";
  # print "result:\n$result\n";

  $self->assert($expected_result eq $result);
} ## end sub test_create_file

sub it {
  my $hashptr = shift();
  return $hashptr;
}

############################
sub test_create_collection {
############################

  my ($self) = @_;

  $self->test_create_file();

  #  print STDERR "file: $file\n";
  $self->{'blah'}->file_name($file);
  my $result = $self->{'blah'}->create_collection(\&it);

  my @expected = qw (Alejandro Diego Zorro);
  my @result   = sort (map { $_->{'name'} } @$result);

  foreach (qw(1 2 3)) {

    #    print "expected_result: $expected[$_]\n";
    #    print "result: $result[$_]\n";
    $self->assert($expected[$_] eq $result[$_], "compare name $_");
  }
  @expected = qw (Don Don Senor);
  @result   = sort (map { $_->{'title'} } @$result);

  foreach (qw(1 2 3)) {

    #    print "expected_result: $expected[$_]\n";
    #    print "result: $result[$_]\n";
    $self->assert($expected[$_] eq $result[$_], "compare title $_");
  }
  @expected = qw (1 2 3);
  @result   = sort (map { $_->{'recid'} } @$result);

  foreach (qw(1 2 3)) {

    #    print "expected_result: $expected[$_]\n";
    #    print "result: $result[$_]\n";
    $self->assert($expected[$_] eq $result[$_], "compare recid $_");
  }
} ## end sub test_create_collection

######################
sub test_create_hash {
######################

  my ($self) = @_;

  $self->test_create_file();

  #  print STDERR "file: $file\n";
  $self->{'blah'}->file_name($file);
  my $result = $self->{'blah'}->create_hash(\&it, 'recid');

  my @expected_names  = qw(Diego Alejandro Zorro);
  my @expected_titles = qw(Don Don Senor);

  foreach my $rec (qw(1 2 3)) {
    my $record = $result->{$rec};

    #    print "record: ", &Dumper($record), "\n";
    $self->assert($record->{'name'} eq $expected_names[ $rec - 1 ],
                  "record $rec name");
    $self->assert($record->{'title'} eq $expected_titles[ $rec - 1 ],
                  "record $rec title");
    $self->assert($record->{'recid'} eq $rec, "record $rec recid");
  } ## end foreach my $rec (qw(1 2 3))
} ## end sub test_create_hash

###########################
sub test_create_list_hash {
###########################

  my ($self) = @_;

  my $data = <<EOT;
[1-1]
recid=1-1
name=Diego
title=Don
[1-2]
recid=1-2
name=Zorro
title=Senor
[2-1]
recid=2-1
name=Alejandro
title=Don
[2-2]
recid=2-2
name=Alex
title=Dad
[3]
recid=3
name=Garcia
title=Sargent
EOT

  local * FILE;
  open(FILE, '>', $file);
  print FILE $data;
  close FILE;

  #  print STDERR "file: $file\n";
  $self->{'blah'}->file_name($file);
  my $result = $self->{'blah'}->create_list_hash(\&it, 'recid');

  #  print &Dumper($result), "\n";

  my @expected_keys    = qw(1 2);
  my @expected_names_1 = qw(Diego Zorro);
  my @expected_names_2 = qw(Alejandro Alex);

  my $list = $result->{1};
  foreach my $idx (qw (1 2)) {
    my $record = $list->[$idx];
    $self->assert($record->{'name'} eq $expected_names_1[$idx],
                  $expected_names_1[$idx]);
  }

  my $list = $result->{2};
  foreach my $idx (qw (1 2)) {
    my $record = $list->[$idx];
    $self->assert($record->{'name'} eq $expected_names_2[$idx],
                  $expected_names_2[$idx]);
  }

  $list = $result->{3};
  my $record = shift(@$list);
  $self->assert($record->{'name'} eq 'Garcia');
} ## end sub test_create_list_hash

1;
