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

package RHN::GPG::OpenPGP;

use Crypt::OpenPGP;
use File::Temp qw/tempfile/;

sub gpg_object {
  my $class = shift;
  my $keyring = shift;

  my @args;
  if ($keyring) {
    push @args, SecRing => $keyring, PubRing => $keyring;
  }
  my $gpg = new Crypt::OpenPGP(Compat => 'GnuPG', @args);

  return $gpg;
}

sub encrypt {
  my $class = shift;
  my $recipient = shift;
  my $data = shift;
  my $keyring = shift;

  my $gpg = RHN::GPG->gpg_object($keyring);
  my ($fh, $fn) = tempfile(DIR => "/tmp");
  my ($ofh, $ofn) = tempfile(DIR => "/tmp");
  unlink $fn;
  unlink $ofn;

  print $fh $data;
  seek $fh, 0, 0;

  $gpg->encrypt(plaintext => $fh, output => $ofh, armor => 1, recipient => $recipient);

  seek $ofh, 0, 0;
  local $/ = undef;

  my $ret = <$ofh>;

  close $fh;
  close $ofh;

  return $ret;
}

sub decrypt {
  my $class = shift;
  my $passphrase = shift;
  my $data = shift;
  my $keyring = shift;

  my $gpg = RHN::GPG->gpg_object($keyring);
  my ($fh, $fn) = tempfile(DIR => "/tmp");
  my ($ofh, $ofn) = tempfile(DIR => "/tmp");
  unlink $fn;
  unlink $ofn;

  print $fh $data;
  seek $fh, 0, 0;

  $gpg->decrypt(ciphertext => $fh, output => $ofh, passphrase => $passphrase);

  seek $ofh, 0, 0;
  local $/ = undef;

  my $ret = <$ofh>;

  close $fh;
  close $ofh;

  return $ret;
}

sub sign {
  my $class = shift;
  my $passphrase = shift;
  my $data = shift;
  my $user = shift;
  my $keyring = shift;

  my $gpg = RHN::GPG->gpg_object($keyring);

  my $ret = $gpg->sign(Data => $data,
		       Passphrase => $passphrase,
		       Detach => 1,
		       Armour => 1,
		       KeyID => $user);
  warn "err: " . $gpg->errstr unless defined $ret;

  return $ret;
}

sub verify {
  my $class = shift;
  my $signature = shift;
  my $data = shift;
  my $keyring = shift;

  my $gpg = RHN::GPG->gpg_object($keyring);

  my @ret = $gpg->verify(Signature => $signature,
			 Data => $data);

  if (@ret) {
    my ($userid, $sig) = @ret;

    my $inner_keyring = new Crypt::OpenPGP::KeyRing(Filename => $gpg->{cfg}->get('PubRing'));
    my @users = $inner_keyring->find_keyblock_by_keyid($sig->key_id);

    if (@users == 0) {
      warn "err: user '$userid' not in keyring $keyring";
      return;
    }
    elsif (@users > 1) {
      warn "err: user '$userid' matches multiple keys";
      return;
    }
    my $block = $users[0];
    my $key = $block->key;

    return { sigid => undef,
	     date => undef,
	     timestamp => $key->timestamp,
	     keyid => $key->key_id_hex,
	     user => $block->primary_uid,
	     fingerprint => $key->fingerprint_hex,
	     trust => undef }
  }
  else {
    warn "verify err: " . $gpg->errstr;
  }

  return;
}

1;
