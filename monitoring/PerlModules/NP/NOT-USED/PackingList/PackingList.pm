##############################
package NOCpulse::PackingList;
##############################

use vars qw($VERSION);
$VERSION = (split(/\s+/,
     q$Id: PackingList.pm,v 1.11 2002-06-07 21:03:08 cvs Exp $,
     4))[2];

use strict;

###########
# Methods #
###########

###########
sub new   {
###########

  my ($class) = @_;
  my $self  = {};
  bless $self, $class;

  return $self;
}

# Accessor methods
sub required_users      { shift->_elem('required_users',    @_); }
sub required_packages   { shift->_elem('required_packages',    @_); }
sub remove_packages     { shift->_elem('remove_packages',    @_); }
sub install_packages    { shift->_elem('install_packages',    @_); }
sub debug               { shift->_elem('debug',    @_); }

###########
sub _elem {
###########
# Stolen from LWP::MemberMixin

  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

#####################
sub createHash      {
#####################
  my ($line,$comment)=@_;
  my %hash={};
  my ($line2,$pkg) =split(/\|/,$line);
  my ($name, $build, @args, $line3);

  if ($line2 =~ /,/)
  {
    #this contains a BUILD file name
    ($name, $line3)= split(/,/,$line2);
    $line3 =~ s/^\s*//;
    ($build, @args)=split(/\s+/,$line3);
  } else {
    ($name, @args)=split(/\s+/,$line2);
  }

  $hash{'name'}   =&trimString($name);
  $hash{'build'}  =&trimString($build) if defined($build);
  $hash{'package'}=&trimString($pkg)   if defined($pkg);
  $hash{'args'}   =join(' ',@args);
  $hash{'comment'}=$comment;
  return \%hash;
}

############
sub absorb {
############

  my ($self, $manifest_file)=@_;

  open(FILE,$manifest_file) || die "ERROR reading manifest data: $!";

  my %hash = map { $_ => [] } qw (Require_Users Require_Packages Install_Packages Remove_Packages);

  my $key;
  my $comment;
  while (<FILE>)
  {
    ($_,$comment) = split(/#/); #weed out comments
    if (/^\s*%.*%\s*$/)
    {

      s/^\s*%(.*)%\s$*/\1/;
      s/\s/_/g;
      $key = $_;

    } else {

      s/^\s*$//g;
      s/^\s*(\S.*\S)\s*$/\1/;
      my $elem=$hash{$key};
      chomp($comment);
      push(@$elem,&createHash($_,$comment)) unless /^$/;
    }
  }

  $self->required_users(   $hash{'Require_Users'});
  $self->required_packages($hash{'Require_Packages'});
  $self->remove_packages(  $hash{'Remove_Packages'});
  $self->install_packages( $hash{'Install_Packages'});
}

#########################
sub transcribeHashArray {
#########################

 my ($self, $handle, $arrayptr, $label)=@_;

  print $handle "$label\n";

  my ($item,$name);
  foreach $item (@$arrayptr) {

    foreach $name (split(/,/,$item->{'name'}))
    {
      print $handle $name; 
      unless($item->{'args'} =~ /^\s*$/)
      {
        print $handle ' ', $item->{'args'};
      }
      unless($item->{'comment'} =~ /^\s*$/)
      {
        print $handle ' #', $item->{'comment'};
      }
      print $handle "\n";
    }

  }
  print $handle "\n";
}

################
sub transcribe {
################

  my ($self, $file, $comment)=@_;
  my $tmp;

  open(FILE, "> $file") || die "Unable to open file $file: $!";

  print FILE "# $comment\n\n";

  $self->transcribeHashArray(\*FILE, $self->required_users,    "%Require Users%");
  $self->transcribeHashArray(\*FILE, $self->required_packages, "%Require Packages%");
  $self->transcribeHashArray(\*FILE, $self->remove_packages,   "%Remove Packages%");
  $self->transcribeHashArray(\*FILE, $self->install_packages,  "%Install Packages%");

  close(FILE);
}

#################
sub trimString {
#################
  my ($string)=@_;
  $string =~ s/^\s*(.*[^\s])\s*$/$1/;
  return $string;
}
