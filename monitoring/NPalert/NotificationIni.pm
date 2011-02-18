package NOCpulse::Notif::NotificationIni;

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw(key_field file_name)];
use Config::IniFiles;

##################
sub create_file {
##################

  my ($self, $arrayptr, @fields_to_include) = @_;

  if (ref($arrayptr) eq 'HASH') {
    $arrayptr = \values(%$arrayptr);
  }

  local * FILE;
  open(FILE, '>', $self->file_name())
    || die("Unable to open file" . $self->file_name());

  unless (@fields_to_include) {
    my $first = @$arrayptr[0];
    @fields_to_include = sort(keys(%$first));
  }

  my $item;
  foreach $item (@$arrayptr) {
    print FILE '[', $item->{ $self->key_field }, "]\n";

    foreach (@fields_to_include) {
      print FILE lc($_), '=';
      my $value = $item->{$_};
      if (ref($value)) {
        print FILE join(',', @$value);
      } else {
        $value =~ s/[\r\n]//g;
        print FILE $value;
      }
      print FILE "\n";
    } ## end foreach (@fields_to_include)
  } ## end foreach $item (@$arrayptr)

  close(FILE);
} ## end sub create_file

#######################
sub create_collection {
#######################

  my ($self, $create_fn) = @_;

  unless (-e $self->file_name()) {
    die("no file " . $self->file_name() . " $!");
  }

  my $arrayptr = [];

  if (-s $self->file_name()) {

    #File contains data

    my $cfg = Config::IniFiles->new(-file => $self->file_name());
    unless ($cfg) {
      die("unable to create ini  from " . $self->file_name() . " $!");
    }

    foreach my $sect ($cfg->Sections()) {
      my %value = map { $_ => $cfg->val($sect, $_) } $cfg->Parameters($sect);
      my $object = &$create_fn(\%value);
      push(@$arrayptr, $object);
    }
  } ## end if (-s $self->file_name...

  return $arrayptr;
} ## end sub create_collection

#################
sub create_hash {
#################

  my ($self, $create_fn, $key_name) = @_;

  unless (-e $self->file_name()) {
    die("no file " . $self->file_name() . " $!");
  }

  my $hashptr = {};

  if (-s $self->file_name()) {

    #File contains data

    my $cfg = Config::IniFiles->new(-file => $self->file_name());
    unless ($cfg) {
      die("unable to create ini  from " . $self->file_name() . " $!");
    }

    die("bad function") unless ref($create_fn) eq 'CODE';

    foreach my $sect ($cfg->Sections()) {
      my %value = map { $_ => $cfg->val($sect, $_) } $cfg->Parameters($sect);
      my $key = $key_name ? $value{$key_name} : $sect;
      my $object = &$create_fn(\%value);
      $hashptr->{$key} = $object;
    }
  } ## end if (-s $self->file_name...

  return $hashptr;
} ## end sub create_hash

######################
sub create_list_hash {
######################

  my ($self, $create_fn, $key_name, $separator) = @_;

  unless (-e $self->file_name()) {
    die("no file " . $self->file_name() . " $!");
  }

  my $hashptr = {};

  if (-s $self->file_name()) {

    #File contains data

    my $cfg = Config::IniFiles->new(-file => $self->file_name());
    unless ($cfg) {
      die("unable to create ini  from " . $self->file_name() . " $!");
    }

    die("bad function") unless ref($create_fn) eq 'CODE';

    foreach my $sect ($cfg->Sections()) {
      my %value = map { $_ => $cfg->val($sect, $_) } $cfg->Parameters($sect);
      my $key_pair = $key_name ? $value{$key_name} : $sect;
      my ($key) = split(/$separator/, $key_pair);
      my $object = &$create_fn(\%value);
      unless (ref($hashptr->{$key}) eq "ARRAY") {
        $hashptr->{$key} = [];
      }
      my $ref = $hashptr->{$key};
      push(@$ref, $object) if $ref;
    } ## end foreach my $sect ($cfg->Sections...
  } ## end if (-s $self->file_name...

  return $hashptr;
} ## end sub create_list_hash

1;

=head1 NAME

NOCpulse::Notif::NotificationIni - A mechanism for creating ini files from key value pairing.

=head1 SYNOPSIS

# Create a new notification ini object
$ini = NOCpulse::Notif::NotificationIni->new(
  'key_field' => 'description',
  'file_name' => '/tmp/customers.ini' );

# Create an ini file of customers from a pointer to an array of hashes containing customer data
$ini->create_file($customer_hash);

# Create an ini file of customers, only containing specific fields
$ini->create_file($customer_hash,'recid','description');

# Create a a reference to an array of data containing hashes of customer data, obtained from the file
$fn=sub { my %hash = @_; return \%hash };
$arrayptr=$ini->create_collection($fn);

# Create a a reference to an hash of data indexed by recid, containing hashes of customer data, obtained from the file
$fn=sub { my %hash = @_; return \%hash };
$hashptr=$ini->create_collection($fn,'recid');

=head1 DESCRIPTION

The C<NotificationIni> object creates ini files from data contained in hashes, and also reads data into hashes from ini files.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the specified arguments.

=back

=head1 METHODS

=over 4

=item create_collection( $fn )

Create a collection of items by reading the ini file.  Required parameter is a reference to a function which takes a hash as an argument, and uses the data from the hash to create another data structure such as an object, that will be stored in the collection returned by this method.

=item create_file ( $arrayptr, [@fields_to_include] )

Create an ini file, named by the file_name attribute, from a reference to an array of hashes.  The hashes must contain key value pairs which will be translated into entries under an ini section.  The ini section names are determined by the key_field attribute.  The option fields_to_include parameter will limit by key, the number of entries in each ini file section.

=item create_hash( $fn, $key )

Create a hash of items, keyed by the specified hash key, by reading the ini file.  Required parameter is a reference to a function which takes a hash as an argument, and uses the data from the hash to create another data structure such as an object, that will be stored in the hash returned by this method.

=item create_list_hash( $fn, $key, $separator )

Create a hash of item lists, assuming $key to be a compound key string, seperated by $seperator.  Groups all the items into a list whose first key part is identical.  The lists are stored as values in the hash, whose key is the first part of $key.  See create_hash for more details.

=item key_field ( [$key] )

Get or set the name from the hash of the field by which to name the ini file sections.

=item file_name ( [$filename] )

Get or set the ini file name on which this object should operate.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-06-03 20:05:54 $

=head1 SEE ALSO

B<NOCpulse::Notif::NotifIniInterface>
B<generate-config>

=cut

