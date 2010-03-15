#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

use strict;

package RHN::Cert;

use XML::LibXML;
use IO::File;
use File::Temp ();
use IPC::Open3;
use RHN::Exception qw/throw/;

sub new {
  my $class = shift;

  my $self = bless { }, $class;

  $self->_init();

  return $self;
}

sub _init {
  my $self = shift;

  throw "Can't call _init() on RHN::Cert abstract base class";
}

sub parse_cert {
  my $class = shift;
  my $data = shift;

  $data =~ s/^\s+$//gm;

  my $p = new XML::LibXML;
  my $doc = $p->parse_string($data);
  my $root = $doc->getDocumentElement();

  throw "invalid root" unless $root->getName eq 'rhn-cert';

  my ($signature_node) = $root->findnodes('rhn-cert-signature');
  my $signature = $signature_node ? $signature_node->getFirstChild->getData : undef;

  my @fields;
  my @extended_fields;

  foreach my $field_node ($root->findnodes('rhn-cert-field')) {
    my $name = $field_node->getAttribute('name');

    my @attributes = map { $_->getName } $field_node->getAttributes;

    # more than 1 means we had something besides name
    if (@attributes > 1) {
      push @extended_fields, [ $name, map { $_, $field_node->getAttribute($_) } grep { $_ ne 'name' } @attributes ];
    }
    else {
      if ($field_node->getFirstChild) {
	my $value = $field_node->getFirstChild->getData;

	push @fields, [ $name, $value ];
      }
      else {
	push @fields, [ $name, '' ];
      }
    }
  }

  my $cert = new $class;
  # $cert->add_field($_->[0]) foreach @fields;
  $cert->set_field($_->[0], $_->[1]) foreach @fields;

  $cert->push_field("name", @$_) foreach @extended_fields;

  return $signature, $cert;
}

sub add_field {
  my $self = shift;
  my @fields = shift;

  push @{$self->{fields}}, @fields;
}

sub clear_field {
  my $self = shift;
  my $field = shift;

  delete $self->{field_values}->{$field};
}

sub set_field {
  my $self = shift;
  my $field = shift;
  my $val = shift;

  die "Field '$field' not allowed" unless grep { $_ eq $field } @{$self->{fields}};
  $self->{field_values}->{$field} = $val;
}

sub push_field {
  my $self = shift;
  my %vals = @_;

  my $field = delete $vals{name};
  die "no field in @_" unless $field;

  push @{$self->{field_values}->{$field}}, \%vals;
}

sub get_field {
  my $self = shift;
  my $field = shift;

  return $self->{field_values}->{$field};
}

sub as_checksum_string {
  my $self = shift;

  my $data;
  foreach my $field (sort @{$self->{fields}}) {
    my $val = $self->get_field($field);

    next unless exists $self->{field_values}->{$field};

    if (defined $val) {
      if (ref $val) {
	foreach my $val (sort { join("", sort %$a) cmp join("", sort %$b) } @$val) {
	  $data .= "$field-" . join("-", map { $_, $val->{$_} } sort keys %$val) . "\n";
	}
      }
      else {
	$data .= $field . "-" . $self->get_field($field) . "\n";
      }
    }
  }

  return $data;
}

sub check_signature {
  my $self = shift;
  my $signature = shift;
  my $keyring = shift;

  $self->check_required_fields;
  my $data = $self->as_checksum_string;

  my $data_file = new File::Temp(UNLINK => 1);
  print $data_file $data;
  $data_file->close();

  my $sig_file = new File::Temp(UNLINK => 1);
  print $sig_file $signature;
  $sig_file->close();

  system('gpg', '--verify', '-q', '--keyring', $keyring, $sig_file->filename(), $data_file->filename());

  my $retval = $? >> 8;
  return ($retval == 0) ? 1 : 0;
}

sub compute_signature {
  my $self = shift;
  my $passphrase = shift;
  my $signer = shift;

  $self->check_required_fields;

  my $data = $self->as_checksum_string;

  my $data_file = new File::Temp(UNLINK => 1);
  print $data_file $data;
  $data_file->close();

  my $pid = IPC::Open3::open3(my $wfh, my $rfh, '>&STDERR',
         qw|gpg -q --batch --yes --passphrase-fd 0 --sign --detach-sign --armor
                -o /dev/stdout --local-user|, $signer, $data_file->filename()) or return;
  print $wfh $passphrase;
  close $wfh;

  my $out;
  {
  local $/ = undef;
  $out = <$rfh>;
  }
  close $rfh;

  waitpid $pid, 0;

  return $out;
}

sub set_required_fields {
  my $self = shift;
  my @fields = @_;

  $self->{required_fields} = \@fields;
}

sub check_required_fields {
  my $self = shift;

  foreach my $f (@{$self->{required_fields}}) {
    throw "Required field $f not found in $self"
      unless defined $self->{field_values}->{$f};
  }
}

sub to_string {
  my $self = shift;
  my $passphrase = shift;
  my $signer = shift;

  $self->check_required_fields;

  my $document = XML::LibXML->createDocument('1.0', 'UTF-8');
  my $root_element = new XML::LibXML::Element('rhn-cert');
  $root_element->setAttribute(version => "0.1");
  $document->setDocumentElement($root_element);

  foreach my $field (@{$self->{fields}}) {
    if (not exists $self->{field_values}->{$field}) {
      if (grep { $field eq $_ }  $self->{required_fields}) {
        die "required field '$field' not present in cert at time of writing";
      }
      else {
        next;
      }
    }

    if (ref $self->get_field($field)) {
      my $fields = $self->get_field($field);

      for my $href (@$fields) {
        my $element = new XML::LibXML::Element("rhn-cert-field");
        $element->setAttribute(name => $field);
        $element->setAttribute($_ => $href->{$_}) for keys %$href;
        $root_element->appendChild($element);
      }
    }
    else {
      my $element = new XML::LibXML::Element("rhn-cert-field");
      $element->setAttribute(name => $field);
      $element->appendText($self->get_field($field));

      $root_element->appendChild($element);
    }
  }

  my $sig_element = new XML::LibXML::Element("rhn-cert-signature");
  if ($signer) {
    my $sig = $self->compute_signature($passphrase, $signer);
    $sig = "\n$sig" unless $sig =~ /^\n/;
    $sig_element->appendText($sig);
  }
  else {
    my $comment = XML::LibXML::Comment->new( "Insert signature here." );
    $sig_element->appendChild($comment);
  }

  $root_element->appendChild($sig_element);

  return $document->toString(1);
}

sub write_to_file {
  my $self = shift;
  my $filename = shift;
  my $passphrase = shift;
  my $signer = shift;

  my $cert = $self->to_string($passphrase, $signer);

  my $file = new IO::File;
  $file->open(">$filename") or die "open $filename: $!";
  $file->print($cert);
}

1;
