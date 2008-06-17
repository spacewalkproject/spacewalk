package test::TestAlertFile;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::AlertFile;
use NOCpulse::Notif::Alert;

my $MODULE = 'NOCpulse::Notif::AlertFile';

my $directory="/tmp";
my $file="$directory/${MODULE}_file_$$";
my $lock="$file.lock";


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

  $self->{'file'}=$MODULE->new( 
      file => $file,
      alert => NOCpulse::Notif::Alert->new(alert_id => 1));
}

###############
sub tear_down {
###############
  my $self=shift;

  `rm -rf $file $lock`;
}

#######################
sub test_acquire_lock {
#######################
  my $self=shift;

  $self->{'file'}->acquire_lock;
  $self->assert(-e $lock, "test_acquire_lock");
}

#######################
sub test_release_lock {
#######################
  my $self=shift;

  $self->{'file'}->acquire_lock;
  $self->assert(-e $lock, "(pre) lock exists");
  $self->{'file'}->release_lock;
  $self->assert(! -e $lock, "test_release_lock");
}

#####################
sub test_close_file {
#####################
  my $self=shift;
  
  $self->assert(! -e $file, "(pre) file exists");

  $self->{'file'}->acquire_lock;
  $self->{'file'}->close_file;
  $self->assert(-e $file, "file exists");

  my $alert=NOCpulse::Notif::Alert->from_file($file);
  $self->assert($alert->alert_id == 1, "test_close (alert contents)");

  $self->assert(! -e $lock, "test_release_lock");
}

################
sub test_write {
################
  my $self=shift;
  
  my $filename=$self->{'file'}->file;
  $self->assert(! -e $filename, "(pre) file exists");

  $self->{'file'}->acquire_lock;
  $self->{'file'}->write;
  $self->assert(-e $filename, "file exists");

  my $alert=NOCpulse::Notif::Alert->from_file($filename);
  $self->assert($alert->alert_id == 1, "test_write (alert contents)");
}

#################
sub test_delete {
#################
  my $self=shift;
  my $f= $self->{'file'};
  $f->acquire_lock;
  $f->write;

  $self->assert(-e $file,"file exists"); 
  $self->assert(-e $lock,"lock exists"); 
  
  $f->delete;

  $self->assert(! -e $file,"file gone"); 
  $self->assert(! -e $lock,"lock gone"); 
}

####################
sub test_open_file {
####################
  my $self=shift;
  my $f= $self->{'file'};
  $f->acquire_lock;
  $f->write;
  $f->close_file;

  my $new_f=$MODULE->open_file($file);
  my $alert=$new_f->alert;

  $self->assert(qr/NOCpulse::Notif::Alert/,"$alert");
}


#######################
sub test_remove_locks {
#######################
  my $self=shift;

  my $test1=$MODULE->new( 
      file => "$file-1",
      alert => NOCpulse::Notif::Alert->new (alert_id => 1));

  $test1->acquire_lock;
  my $lock=$test1->_lock;
  $MODULE->remove_locks($directory,'runtest',$$);
  $self->assert(! -e $lock,"test1 $lock exists");

  $test1->acquire_lock;
  $MODULE->remove_locks($directory,'runtest');
  $self->assert(! -e $lock,"test2 $lock exists");

  $test1->acquire_lock;
  $MODULE->remove_locks($directory);
  $self->assert(! -e $lock,"test3 $lock exists");

  $test1->acquire_lock;
  $MODULE->remove_locks($directory,'runtest',99999999);
  $self->assert(-e $lock,"test4 $lock exists");

  $MODULE->remove_locks($directory,'runbad');
  $self->assert(-e $lock,"test5 $lock exists");

  $MODULE->remove_locks($directory,'runtest',$$);
}

1;

