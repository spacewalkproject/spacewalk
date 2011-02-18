#!/usr/bin/perl

package NOCpulse::Config;
use Carp;

use vars qw($VERSION);
$VERSION = (split(/\s+/,
	   q$Id: Config.pm,v 1.11 2002-04-08 21:14:48 rmcchesney Exp $,
	   4))[2];

my $FILENAME   = "/etc/NOCpulse.ini";

my $FILE_CONTENTS = ();

sub new {
  my($class, $filename) = @_;
  $filename ||= $FILENAME;
  my $self = { contents => {} };
  bless $self, $class;

  return $self->load_config($filename);

}


sub filename {
    return $self->{filename};
}


sub load_config {
  my($self, $filename) = @_;

  $self->{filename} = $filename;

  # Return the cached version if it's there.
  if (exists($FILE_CONTENTS{$filename})) {
      $self->{contents} = $FILE_CONTENTS{$filename};
      return $self;
  }

  my($section);

  local * FILE;
  unless (open(FILE, '<', $filename)) {
    $@ = "Couldn't open $filename: $!";
    return undef;
  }

  while (<FILE>) {
    s/#.*$//g;          # Remove comments
    next unless (/\S/); # Skip blank lines
    chomp;


    if (/^\[([^]]+)\]/) {
      $section = $1;

      if (exists($self->{contents}->{$section})) {
        carp("Duplicate section '$section'\n");
      }

    } else {

      my($key, $val) = split(/=/, $_, 2);
      if (exists($self->{contents}->{$section}->{$key})) {

        carp("Ignoring duplicate entry $section -> $key\n");

      } else {

	$self->{contents}->{$section}->{$key} = $val;

      }
    }
  }
  close(FILE);

  $FILE_CONTENTS{$self->{filename}} = $self->{contents};

  return $self;

}



sub get {
  my($self, $section, $key) = @_;

  return $self->{contents}->{$section}->{$key};

}



sub getSection {
  my($self, $section) = @_;

  return $self->{contents}->{$section};

}



sub getContents {
  my($self, $section, $key) = @_;

  # Get the contents of a file named by a parameter, rather than the
  # parameter itself.

  my $filename = $self->get($section, $key);

  if (defined($filename)) {
    local * FILE;
    if (open(FILE, '<', $filename)) {
      my $contents = join('', <FILE>);
      close(FILE);
      return $contents;
    } else {
      carp("Couldn't open $filename: $!");
      return undef;
    }
  } else {
    carp("No key '$key' in '$section' section\n");
    return undef;
  }
}



sub val {
  # DAP - added this so I don't have to recode my old stuff
  goto &get;
}


# Class method
sub clearCached {
    my ($class, $filename) = @_;
    $filename ||= $FILENAME;
    delete $FILE_CONTENTS{$filename};
}


1;

__END__

=head1 NAME

NOCpulse::Config - NOCpulse bootstrap configuration module

=head1 SYNOPSIS

  use NOCpulse::Config;

  my $cfg = new NOCpulse::Config;

  # Example:  Oracle parameters for the config database
  my $dbd     = $cfg->get('cf_db', 'dbd');
  my $dbname  = $cfg->get('cf_db', 'name');
  my $dbuname = $cfg->get('cf_db', 'username');
  my $dbpass  = $cfg->get('cf_db', 'password');

  $ENV{'ORACLE_HOME'} = $cfg->get('oracle', 'ora_home');

  my $dbh = DBI->connect("DBI:$dbd:$dbname", $dbuname, $dbpass);


  # Example: get the contents of a file named by a parameter
  my $motd    = $cfg->getContents('general', 'motd_filename');

=head1 DESCRIPTION

The C<NOCpulse::Config> module is a wrapper around the NOCpulse bootstrap
configuration file, currently C</etc/NOCpulse.ini>.

=head1 METHODS

=over 3

=item new()

Create a config object.


=item get($section_name, $parameter_name)

Fetch $parameter_name from section $section_name.  (See the config
file /etc/NOCpulse.ini for section and parameter names.)

=item getContents($section_name, $parameter_name)

Fetch the contents of the file named by parameter $parameter_name from 
section $section_name.  (See the config file /etc/NOCpulse.ini for 
section and parameter names.)

=back

=head1 AUTHOR

Dave Faraldo <david@nocpulse.com>

=head1 LAST UPDATE

$Date: 2002-04-08 21:14:48 $

=cut

