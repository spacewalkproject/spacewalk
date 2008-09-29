#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use IO::Handle ();

use constant RECORD_SIZE => 512;
use constant GIT_BLOCK_SIZE => RECORD_SIZE * 20;

my $stamp = shift;
if (not defined $stamp) {
	die "Please specify stamp to put into the tar as the first parameter.\n";
}
my $stamp_octal = sprintf "%011o", $stamp;
my $comment = shift;
if (defined $comment) {
	if (not $comment =~ /^[0-9a-f]{40}$/) {
		die "The comment we will put into the tar should be SHA1 in hex (40 characters).\n";
	}
}

my $chunk;
my $handle = \*STDIN;
my $read;
my $need_header = 1;
my $total_len = 0;
while ($read = $handle->sysread($chunk, RECORD_SIZE)) {
	# print STDERR "read [$read]\n";
	if ($read < RECORD_SIZE) {
		my $rest = RECORD_SIZE - $read;
		while (my $read = $handle->sysread($chunk, $rest, length($chunk))) {
			# print STDERR "  plus [$read]\n";
			$rest -= $read;
		}
	}

	if ($chunk eq "\0" x 512) {
		# look for the second record full of zeroes
		my $pad;
		my $read = $handle->sysread($pad, RECORD_SIZE);
		if ($read) {
			if ($read < RECORD_SIZE) {
				my $rest = RECORD_SIZE - $read;
				while (my $read = $handle->sysread($pad, $rest, length($pad))) {
					$rest -= $read;
				}
			}
		}
		if ($pad ne "\0" x 512) {
			die "Failed to find second stop record.\n";
		}
		print $chunk;
		print $pad;
		$total_len += length($chunk) + length($pad);
		print "\0" x (padded_record_size($total_len, GIT_BLOCK_SIZE) - $total_len);
		exit;
	}

	my ($name, $data1, $size, $mtime, $checksum, $link, $name2, $data2) = unpack 'A100 A24 A12 A12 A8 A1 A100 a*', $chunk;
	my $block_size = $size ? padded_record_size( oct $size ) : $size;
	# print STDERR "[$name] [$size] [$mtime] [$checksum] [$link] [$name2] [$block_size]\n";

	if ($need_header and $link ne 'g' and defined $comment) {
		my $header = pack 'a100 a8 a8 a8 a12 a12 A8 a1 a100 a6 a2 a32 a32 a8 a8 a155 x12',
			'pax_global_header', (sprintf "%07o", 0666), '0000000', '0000000',
			'00000000064', $stamp_octal, '', 'g', '',
			'ustar', '00', 'root', 'root', '0000000', '0000000', '';
		substr($header, 148, 8) = sprintf("%07o\0", unpack("%16C*", $header));
		print $header;
		print pack "a512", "52 comment=$comment\n";
		$need_header = 0;
		$total_len += 2 * 512;
	}

	my $out = $chunk;
	my $write_comment = 0;
	if ($mtime) {
		substr($out, 136, 12) = pack "a12", $stamp_octal;
		substr($out, 148, 8) = pack "A8", "";
		substr($out, 148, 8) = sprintf("%07o\0", unpack("%16C*", $out));
		if ($link eq 'g' and oct $size == 52) {
			$write_comment = 1;
		}
	}
	print $out;
	$total_len += length $out;

	my $payload;
	while (my $read = $handle->sysread( $payload, $block_size )) {
		if (defined $comment and $write_comment) {
			if ($read < 52) {
				die "Would like to put SHA1 into header but did not read at least 52 bytes.\n";
			}
			if (not $payload =~ /^52 comment=/) {
				die "The header payload is not [52 comment=].\n";
			}
			substr($payload, 0, 52) = "52 comment=$comment\n";
		}
		# print STDERR "  payload [@{[ length $payload ]}]\n";
		print $payload;
		$total_len += length $payload;
		$block_size -= $read;
		last unless $block_size;
	}
}

sub padded_record_size {
	my $len = shift;
	my $pad_size = shift || RECORD_SIZE;
	my $out = int($len / $pad_size);
	$out++ if $len % $pad_size;
	return $out * $pad_size;
}
