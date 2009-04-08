#! /usr/bin/perl -w
# This script imports the rpm package from $inputdir, signes the package(s) and push them into satellite server.
#
# Written by Daniel Steiner 28.8.2004
# Version: 1.1
# Changes: show latest already pushed rpm packages instead of all '--lastonly' option by 22.9.2004 Daniel Steiner
# Changes: list latest pushed and latest available package in a overview '--compare' option by 22.9.2004 Daniel Steiner
# Changes: now, compare function gets the already pushed packages from satellite server. by Daniel Steiner 20.1.2005
# Changes:
#
############################################################################
#    Copyright (C) 2005 by Daniel Steiner                                  #
#    daniel-steiner@bluewin.ch                                             #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
############################################################################
#
# Please check first the 'variables to setup' section!

use strict;
use warnings;
use File::Copy;
#use Term::ANSIColor;
use Term::ANSIColor qw(:constants);

### variables to setup:
# valid login:
my $user = "root";
# should the rpms be cleaned after successfull upload? set it to 1:
my $cleanup = 1;
#my $user = "dani";
# incomming rpm packages directory:
my $inputdir = "/opt/bluewin-rpms-in";
#my $inputdir = "/home/dani/rh-satellite/test";
my $inputdird = 0;
# working directory:
my $signdir = "/opt/bluewin-rpms-signed";
#my $signdir = "/data/test";
my $signdird = 0;
# subtree where the source rpm files are:
my $srpms = "srpms";
# subtree where the binary rpm files are:
my $rpms = "rpms";
# current RedHat version:
my $rhrelease = "es3";
my $rhreleased = 0;
# Allowed releases:
my @releases = ("es3", "as3", "rh8", "rh9", "as2.1", "all");
# rhnpush binary:
my $rhnpush = `which rhnpush`;
chomp $rhnpush;
#my $rhnpush = "/usr/bin/rhnpush";
# account on satellite server for the channels:
my $login = "daniel";
my $logind = 0;
# password for account:
my $password = "angie1";
my $passwordd = 0;
# URL for pushing packages:
my $server = "https://localhost/APP";
my $serverd = $server;
# rpm binary:
my $rpm = `which rpm`;
chomp $rpm;
#my $rpm = "/bin/rpm";
# software channel (no default definition, use '-c' option to define channel!)
my $channel = "";
# possible channels (this is just a helper for easier usage of script, see -c <channel> option):
my @channels = ("webserver", "networking", "drivers", "webserver-as", "networking-as", "drivers-as", "globalfs", "globalfs-as");
# element definition for each channel (which package is acroding to which package):
my %chanpacks = (
				 webserver => [ "httpd", "apache_conf", "jakarta-tomcat", "jk2-connector", "mod_php", "mod_php_mysql", "mod_php_pgsql", "mod_php_magix", "j2sdk-bw", "MySQL", "perl-DBD-MySQL", "libmhash" ],
				 networking => [ "backup-scripts", "openssh", "pine", "rsync", "wget" ],
				 drivers => [ "ibmtape-driver", "lpfcdriver", "bcm5700", "kernel-smp" ],
				 globalfs => [ "GFS", "GFS-devel", "GFS-modules", "GFS-modules-hugemem", "GFS-modules-smp", "rh-gfs-en", "perl-Net-Telnet" ],
				);
# newest version of package:
my $newest = "";
# rhnpush options (optionally):
my $opts = "";
# error status count:
my $stat = 0;
# enable or disable listing of possible packages to push (don't change this value here!):
my $list = 0;
# do nothing, just list possible executions => 1:
my $listing = 0;
# all packages containing sub packages:
my @mysql = ("MySQL");
##########################################################################################
## do not change variables from beginning from here!
##########################################################################################
### init of variables:
my $sourcerpm = "srpms";
my $binrpm = "rpms";
my @rpms = ();
my @opts = ();
my @chan = ();
my @files = ();
my $file = "";
my $ver = "";
my $rel = "";
my $arch = "";
my @sorted = ();
my $fi = "";
my $fo = "";
my $previous = 0;
my $lastonly = 0;
my $compare = 0;
my $as = 0;
my $all = 0;
my $search = "";

### subroutines:
## Usage:
sub usage() {
	print CYAN;
	print ("\n######################################################################################################################################\n");
	print ("Usage:\t$0 <rpm package base name> [ <rpm package base name> ... ] [ -c <channel name> [ -c <channel name> ... ] ] [ -ca ] [ -a ] [ -v ]\n");
	print ("\t[ -p <password> ] [ -l <login> ] [ -i <input direcory> ] [ -d <directory for signed packages> ] [ -o <option> [ -o option ...> ] ] [ -r <redhat release> ]\n");
	print ("or\n\t$0 -l -f <search string> \t=> to list all possible packages to push\n");
	print ("or\n\t$0 -p [ --lastonly ]\t=> to list all previous pushted packages\n");
	print ("or\n\t$0 --compare\t=> to compare the list of already pushed and newest available RPMs\n");
	print ("\n\trpm package base name example\t: httpd => httpd-2.0.50-05.src.rpm\n");
	print ("\t-i\tinput directory\t\t: Folder where the incomming rpms are located\n\t-v\tpreview mode, don't execute the commands just show them.\n");
	print ("\t-a\tto push all packages from directory into satellite (directory is taken from package name!).\n");
	print ("\t-ap\tto push not only newest packages into satellite, but only those given.\n");
	print ("\t-c\tchannel name\t\t: Currently '@channels' are supported in Bluewin.\n");
	print ("\t-ca\tpush all given packages into Redhat AS release, channel name must not contain '-as' at the end!\n\n");
	print ("\tNote: If you give more than one base rpm name and you use the '-c' option, you must give the same amount of channels after '-c' in the same order!\n");
	print ("\n\tdefaults:\n\t\t\tinput directory\t: '$inputdir',\n\tdirectory for signed packages\t: '$signdir'\n");
	print ("\t\t\tRedhat release\t: '$rhrelease'\n\t\t\tlogin\t\t: '$login'\n\t\t\tpassword\t: 'pssst!'\n\t\t\tServer url\t: '$server'\n");
	print ("\nNote:\tDirectory structure must exist in input and signed direcories! This script expects following structure:\n");
	print ("\tRPM input directory:\t\t$inputdir/$rpms/$rhrelease\n\tSRPM input directory:\t\t$inputdir/$srpms\n\tRPM sign (push) directory:\t$signdir/$rpms/$rhrelease\n");
	print ("\tSRPM sign (push) directory:\t$signdir/$srpms\n\n\tIf this structure does not exist, the script asks for directory structure creation!\n");
	print ("######################################################################################################################################\n");
	print ("\n");
	print RESET;
	exit 1;
}

## check for valid current user:
sub checkuser() {
	my @u = ();
	my $l = "";
	print ("\n===>\tChecking for proper login:\n");
	my $login = "";
	$l = `id`;
	chomp $l;
	@u = split (/\s+/, $l);
	foreach (@u) {
		if ($_ =~ /^uid=\d+\(\w+\)/) {
			$login = $_;
			$login =~ s/^uid=\d+\(//;
			$login =~ s/\)//;
		}
	}
	chomp $login;
	if ("$login" eq "$user") {
		print CYAN; print ("=>\tOK\n"); print RESET;
	} else {
		print RED; print ("Error:\tCurren user is '$login', please login as '$user' and try again, stopping here...\n\n"); print RESET;
		exit 1;
	}
}

## check command line arguments:
sub args() {
	my $i = 0;
	my $ok = 0;
	my $check = 0;
	my $skip = 0;
	my $got = 0;
	if (@ARGV > 0) {
		if ($ARGV[0] =~ /^[a-zA-Z]/) {
			push (@rpms, $ARGV[0]);
		} elsif ($ARGV[0] =~ /^--help|^-h/) {
			&usage();
		# list newest possible rpms to push:
		} elsif ($ARGV[0] eq "-l") {
			$list = 1;
			if (@ARGV == 3) {
				if ($ARGV[1] =~ /^-f$/) {
					$search = $ARGV[2];
					$check = 1;
				} else {
					&usage;
				}
			}
		# list already pushed rpms:
		} elsif ($ARGV[0] eq "-p") {
			if (@ARGV == 2) {
				if ($ARGV[1] =~ /^--.+/) {
					if ($ARGV[1] eq "--lastonly") {
						$lastonly = 1;
					} else {
						print ("Error:\tOnly '--lastonly' is allowed in this context!!\n");
						&usage;
					}
					if (2 != @ARGV) {
						print ("Error:\tNo additional argument is allowed to '-p --lastonly' options!!\n");
						&usage;
					}
				}
			}
			$previous = 1;
		} elsif ($ARGV[0] =~ /^--.+/) {
			if ($ARGV[0] eq "--compare") {
				$compare = 1;
			} else {
				print ("Error:\tOnly '--compare' is allowed in this context!!\n");
				&usage;
			}
		} else {
			print RED; print ("Error:\tFirst argument must be a package base name!!!\n"); print RESET;
			&usage();
		}
		if ($check == 0) {
		if (@ARGV > 1) {
			for ($i = 1; $i < @ARGV; $i++) {
				if ($skip == 1) {
					$skip = 0;
					next;
				}
				if (($ARGV[$i] =~ /^[a-zA-Z]/) and ($check == 0)) {
					push (@rpms, $ARGV[$i]);
				} elsif ($ARGV[$i] =~ /^-\w/) {
					# channel:
					$check = 1;
					if ($ARGV[$i] eq "-c") {
						$got = 0;
						foreach (@channels) {
							if ($_ eq "$ARGV[$i+1]") {
								$got++;
							}
						}
						if ($got == 1) {
							push (@chan, $ARGV[$i+1]);
							$skip = 1;
						} else {
							print RED; print ("Error:\tPlease enter a valid channel value '$ARGV[$i] [ @channels ]'\n"); print RESET;
							&usage();
						}
					} elsif($ARGV[$i] eq "-a") {
						$all = 1;
					} elsif($ARGV[$i] eq "-ap") {
						$all = 2;
					} elsif ($ARGV[$i] eq "-ca") {
						$as = 1;
						$rhrelease = "as3";
					# password:
					} elsif ($ARGV[$i] eq "-p") {
						if ($passwordd > 0) {
							print RED; print ("Error:\tYou can enter '$ARGV[$i]' only once!!\n"); print RESET;
							&usage();
						} else {
							$password = $ARGV[$i+1];
							$passwordd++;
							$skip = 1;
						}
					# login:
					} elsif ($ARGV[$i] eq "-l") {
						if ($logind > 0) {
							print RED; print ("Error:\tYou can enter '$ARGV[$i]' only once!!\n"); print RESET;
							&usage();
						} else {
							$login = $ARGV[$i+1];
							$logind++;
							$skip = 1;
						}
					# list the execution:
					} elsif ($ARGV[$i] eq "-v") {
						$listing = 1;
					# input dir:
					} elsif ($ARGV[$i] eq "-i") {
						if ($inputdird > 0) {
							print RED; print ("Error:\tYou can enter '$ARGV[$i]' only once!!\n"); print RESET;
							&usage();
						} else {
							$inputdir = $ARGV[$i+1];
							$inputdird++;
							$skip = 1;
						}
					# sign dir:
					} elsif ($ARGV[$i] eq "-d") {
						if ($signdird > 0) {
							print RED; print ("Error:\tYou can enter '$ARGV[$i]' only once!!\n"); print RESET;
							&usage();
						} else {
							$signdir = $ARGV[$i+1];
							$signdird++;
							$skip = 1;
						}
					# exec options:
					} elsif ($ARGV[$i] eq "-o") {
						push (@opts, $ARGV[$i+1]);
						$skip = 1;
					# release:
					} elsif ($ARGV[$i] eq "-r") {
						if ($rhreleased > 0) {
							print RED; print ("Error:\tYou can enter '$ARGV[$i]' only once!!\n"); print RESET;
							&usage();
						} else {
							$ok = 0;
							if ($rhreleased > 0) {
								print RED; print ("Error:\tYou can enter '$ARGV[$i]' only once!!\n"); print RESET;
							} else {
								foreach (@releases) {
									if ("$_" eq "$ARGV[$i+1]") {
										$ok++;
									}
								}
								if ($ok == 1) {
									$rhrelease = $ARGV[$i+1];
									$rhreleased++;
									$skip = 1;
								} else {
									print RED; print ("Error:\tYou did not enter a valid release: '$ARGV[$i]'!!\n"); print RESET;
									&usage();
								}
							}
						}
					} else {
						print RED; print ("Error:\tArgument, '$ARGV[$i]' is not allowed!!!\n"); print RESET;
						&usage();
					}
				}
			}
		}
		}
	} else {
		print RED; print ("\nError:\tTo few arguments!!\n"); print RESET;
		&usage();
	}
}

## sort, split and get newest rpms files:
sub splitnewestrpm() {
	my @tmp = ();
	my $t = 0;
	my $i = 0;
	my $name = "";
	my $version = "";
	my $release = "";
	my $arch = "";
	my $got = 1;
	@files = sort @files;
	foreach $file (@files) {
		if ($file =~ /^\.$|^\.\.$/) {
		} else {
			if (@rpms > 0) {
				$got = 1;
				foreach (@rpms) {
					if ($file =~ /^$_/) {
						$got = 0;
					}
				}
				if ($got == 1) {
					next;
				}
			}
			$name = "";
			$version = "";
			$release = "";
			$arch = "";
			@tmp = split(/-/, $file);
			for ($i = 0; $i < @tmp; $i++) {
				# get package base name:
				if ($tmp[$i] =~ /^[a-zA-Z]+\w+$/) {
					if ($name eq "") {
						$name = "$tmp[$i]";
					} else {
						$name = "$name-$tmp[$i]";
					}
				# get package version:
				} elsif (($tmp[$i] =~ /^\d+\.\d+/) and ($tmp[$i] !~ /^\d+\.\d+\.\w.+\.rpm$/)) {
					$version = $tmp[$i];
				# get package release:
				} elsif ($tmp[$i] =~ /^(\d+|\d+\.\d+)\.(.+)\.(rpm)$/) {
					$release = $1;
					# get package arch:
					$arch = $2;
				}
			}
			#print ("Base: $name, Version: $version, Release: $release, Arch: $arch\n");
			# push latest version into sorted array:
			if (@sorted == 0) {
				$sorted[$t][0] = $name;
				$sorted[$t][1] = $version;
				$sorted[$t][2] = $release;
				$sorted[$t][3] = $arch;
			} else {
				if ($sorted[$t][0] eq $name) {
					$sorted[$t][0] = $name;
					$sorted[$t][1] = $version;
					$sorted[$t][2] = $release;
					$sorted[$t][3] = $arch;
				} else {
					$t++;
					$sorted[$t][0] = $name;
					$sorted[$t][1] = $version;
					$sorted[$t][2] = $release;
					$sorted[$t][3] = $arch;
				}
			}
		}
	}
}

## create list of rpms in the specified input directory:
sub showlist() {
	my $f = "";
	my $i = 0;
	my $j = 0;
	my $m = 0;
	my @tmp = ();
	@files = ();
	for $rel (@releases) {
		opendir(SRCDIR, "$inputdir/$rpms/$rel");
		@tmp = readdir SRCDIR;
		chomp @tmp;
		@tmp = sort @tmp;
		if (@files == 0) {
			@files = @tmp;
		} else {
			@files = (@files, @tmp);
		}
	}
	&splitnewestrpm();
	print ("\n===>\tListing:\n");
	print ("=============================================================================================================\n");
	print (" Possible packages:\t(only latest available version is listed here!)\n");
	print ("-----------------------------------------------|---------------------------|------------------|--------------\n");
	print ("");
	for $i (0 .. $#sorted) {
		for $j (0 .. $#{$sorted[$i]}) {
			if ($j == 0) {
				$file = $sorted[$i][$j];
			} elsif ($j == 1) {
				$ver = $sorted[$i][$j];
			} elsif ($j == 2) {
				$rel = $sorted[$i][$j];
			} elsif ($j == 3) {
				$arch = $sorted[$i][$j];
			}
		}
		if (-z $search) {
			if ($m == 0) {
				print BLUE; printf ("Package:  %-36s | Version:  %-15s | Arch:  %-9s | Release:  %-3s\n", $file, $ver, $arch, $rel); print RESET;
				$m = 1;
			} else {
				print CYAN; printf ("Package:  %-36s | Version:  %-15s | Arch:  %-9s | Release:  %-3s\n", $file, $ver, $arch, $rel); print RESET;
				$m = 0;
			}
			print ("-----------------------------------------------|---------------------------|------------------|--------------\n");
		} else {
			if ($file =~ /$search/) {
				if ($m == 0) {
					print BLUE; printf ("Package:  %-36s | Version:  %-15s | Arch:  %-9s | Release:  %-3s\n", $file, $ver, $arch, $rel); print RESET;
					$m = 1;
				} else {
					print CYAN; printf ("Package:  %-36s | Version:  %-15s | Arch:  %-9s | Release:  %-3s\n", $file, $ver, $arch, $rel); print RESET;
					$m = 0;
				}
				print ("-----------------------------------------------|---------------------------|------------------|--------------\n");
			}
		}

	}
	print ("=============================================================================================================\n");
}
## split all rpm files:
sub splitall() {
	my @tmp = ();
	my $t = 0;
	my $i = 0;
	my $name = "";
	my $version = "";
	my $release = "";
	my $arch = "";
	my $got = 1;
	@files = sort @files;
	@sorted = ();
	foreach $file (@files) {
		if ($file =~ /^\.$|^\.\.$/) {
		} else {
			if (@rpms > 0) {
				$got = 1;
				foreach (@rpms) {
					if ($file =~ /^$_/) {
						$got = 0;
					}
				}
				if ($got == 1) {
					next;
				}
			}
			$name = "";
			$version = "";
			$release = "";
			$arch = "";
			@tmp = split(/-/, $file);
			for ($i = 0; $i < @tmp; $i++) {
				# get package base name:
				if ($tmp[$i] =~ /^[a-zA-Z]+\w+$/) {
					if ($name eq "") {
						$name = "$tmp[$i]";
					} else {
						$name = "$name-$tmp[$i]";
					}
				# get package version:
				} elsif (($tmp[$i] =~ /^\d+\.\d+/) and ($tmp[$i] !~ /^\d+\.\d+\.\w.+\.rpm$/)) {
					$version = $tmp[$i];
				# get package release:
				} elsif ($tmp[$i] =~ /^(\d+|\d+\.\d+)\.(.+)\.(rpm)$/) {
					$release = $1;
					# get package arch:
					$arch = $2;
				}
			}
			#print ("Base: $name, Version: $version, Release: $release, Arch: $arch\n");
			# push all attributes into array:
			$sorted[$t][0] = $name;
			$sorted[$t][1] = $version;
			$sorted[$t][2] = $release;
			$sorted[$t][3] = $arch;
			$t++;
		}
	}
}

## previous pushed rpm listing:
sub listprevious() {
	my $f = "";
	my $i = 0;
	my $j = 0;
	my $m = 0;
	print ("\n===>\tListing:\n");
	print ("=========================================================================================================================================\n");
	print(" Already pushed RPMs: (from previous sessions, ");
	print GREEN;
	print ("green");
	print RESET;
	print(" succussfully uploaded!)\n");
	print ("--------------------------|-----------------------------------------------|---------------------------|------------------|---------------\n");
	print ("");
	@files = ();
	foreach $channel (@channels) {
		my @tmp = ();
		for $rel (@releases) {
			opendir(SRCDIR, "$signdir/$rpms/$rel/$channel");
			@tmp = readdir SRCDIR;
			chomp @tmp;
			@tmp = sort @tmp;
			if (@files == 0) {
				@files = @tmp;
			} else {
				@files = (@files, @tmp);
			}
		}
	}
	if ($lastonly == 1) {
		&splitnewestrpm();
	} else {
		&splitall();
	}
	for $i (0 .. $#sorted) {
		for $j (0 .. $#{$sorted[$i]}) {
			if ($j == 0) {
				$file = $sorted[$i][$j];
			} elsif ($j == 1) {
				$ver = $sorted[$i][$j];
			} elsif ($j == 2) {
				$rel = $sorted[$i][$j];
			} elsif ($j == 3) {
				$arch = $sorted[$i][$j];
			}
		}
		&selectchannel();
		if (-s "$signdir/$srpms/$channel/$file-$ver-$rel.$arch.rpm") {
			print YELLOW; printf ("Channel:  %-15s | Package:  %-35s | Version:  %-15s | Arch:  %-9s | Release:  %-3s\n", $channel, $file, $ver, $arch, $rel); print RESET;
		} else {
			print GREEN; printf ("Channel:  %-15s | Package:  %-35s | Version:  %-15s | Arch:  %-9s | Release:  %-3s\n", $channel, $file, $ver, $arch, $rel); print RESET;
		}
		print ("--------------------------|-----------------------------------------------|---------------------------|------------------|---------------\n");
	}
	print ("=========================================================================================================================================\n");
}

## channel selection:
sub checkchannel() {
	print ("\n===>\tChecking for proper channels:\n");
	my $i = 0;
	my $in = "";
	my $def = "y";
	my $ok = 0;
	my $ch = "";
	my $out = 0;
	my $packs = 0;
	if (@chan > 0) {
		# check, if given packages have the same count like given channels:
		if (@chan == @rpms) {
			for ($i = 0; $i < @rpms; $i++) {
				$ok = 0;
				foreach $ch (keys %chanpacks) {
					foreach (@{ $chanpacks{$ch} }) {
						if ("$rpms[$i]" eq "$_") {
							print BLUE; print ("=>\t$_ found in $ch(-as) ...\n"); print RESET;
							$ok = 1;
						}
					}
				}
				if ($ok == 0) {
					print ("\nInfo:\tYour given rpm base, '$rpms[$i]' does not belong to one of the predefined channels: \[ @channels \]\n");
					$out = 0;
					while ($out == 0) {
						print YELLOW; print ("\tIf it is a new package and should belong to on of the predefined channels, you can continue. Do you agree? [Y|n] "); print RESET;
						$in = <STDIN>;
						chomp $in;
						if ($in eq "") {
							$in = $def;
						}
						if ($in =~ /^y$|^Y$/) {
							$out = 1;
						} elsif ($in =~ /^n$|^N$/) {
							$out = 2;
							exit 4;
						}
					}
				}
			}
		} else {
			print RED; print ("\nError:\tThe amount of given channels must be equal to amount of rpm package names!!\n\n"); print RESET;
			exit 3;
		}
	} else {
		# search the according channel to rpm base (no -c option!):
		$packs = 0;
		for ($i = 0; $i < @rpms; $i++) {
			$ok = 0;
			foreach $ch (keys %chanpacks) {
				foreach (@{ $chanpacks{$ch} }) {
					if ("$rpms[$i]" eq "$_") {
						print BLUE; print ("=>\t$_ found in $ch ...\n"); print RESET;
						$ok = 1;
						$packs++;
					}
				}
			}
			if ($ok == 0) {
				print RED; print ("\nError:\tYour given rpm base, '$rpms[$i]' does not belong to one of the predefined channels: \[ @channels \]\n\n"); print RESET;
			}
		}
		if ($packs != @rpms) {
			print RED; print ("\nError:\tCannot find all given RPMs in channels, abording now!!!\n\n"); print RESET;
			exit 5;
		}
	}
}

## check existence of input and sign directories:
sub checkdirs() {
	my $check = 0;
	my @createdir = ();
	my $in = "";
	my $out = 0;
	my $def = "y";
	my $rc = 0x0;
	if (!-d "$inputdir") {
		$createdir[$check] = $inputdir;
		$check++;
	}
	if (!-d "$signdir") {
		$createdir[$check] = $signdir;
		$check++;
	}
	foreach (@channels) {
		if (!-d "$signdir/$rpms/$rhrelease/$_") {
			$createdir[$check] = "$signdir/$rpms/$rhrelease/$_";
			$check++;
		}
		if (!-d "$signdir/$srpms/$_") {
			$createdir[$check] = "$signdir/$srpms/$_";
			$check++;
		}
	}
	if ($check > 0) {
		while ($out == 0) {
			print ("===>\tFollowing directories are not existing on your system:\n");
			print RED;
			foreach (@createdir) {
				print ("\t$_\n");
			}
			print RESET;
			print ("\t, shall I create them? [Y|n] ");
			$in = <STDIN>;
			chomp $in;
			if ($in eq "") {
				$in = $def;
			}
			if ($in =~ /^y$|^Y$/) {
				$out = 1;
			} elsif ($in =~ /^n$|^N$/) {
				$out = 2;
			}
		}
		if ($out == 2) {
			print YELLOW; print ("Warn:\tI cannot continue without existing diretories, abording now ...\n\n"); print RESET;
			exit 0;
		} else {
			$out = 0;
			foreach (@createdir) {
				if ($listing == 1) {
					print MAGENTA; print ("-->\tmkdir -p $_\n"); print RESET;
				} else {
					$rc = 0xffff & system("mkdir", "-p", "$_");
					if ($rc == 0) {
						print GREEN; print("$_ created successfull.\n"); print RESET;
					} elsif (($rc & 0xff) == 0) {
						print RED; print("$_ not created!!\n"); print RESET;
						$out++;
					}
				}
			}
			if ($out > 0) {
				print RED; print ("\nError:\tExiting now...\n\n"); print RESET;
				exit 2;
			}
		}
		print ("\n");
	}
}

## select the proper channel for given file:
sub selectchannel() {
	my $i = 0;
	my $ch = "";
	foreach $ch (keys %chanpacks) {
		foreach (@{ $chanpacks{$ch} }) {
			if ($file =~ /^$_/) {
				if ($as == 1) {
					$channel = "$ch-as";
				} else {
					$channel = $ch;
				}
			}
		}
	}
}

## push the desired rpms and srpms into satellite db:
sub pushrpms() {
	my $i = 0;
	my $j = 0;
	my $e = 0;
	my $g = 0;
	my @tmp = ();
	my $rc = 0x0;
	my @args = ();
	# write options into $opts variable:
	if (@opts > 0) {
		foreach (@opts) {
			if ($opts eq "") {
				$opts = "$_";
			} else {
				$opts = "$opts $_";
			}
		}
	}
	print ("\n===>\tPush the RPMs into satellite web:\n");
	## rpms:
	opendir(SRCDIR, "$inputdir/$rpms/$rhrelease");
	@files = readdir SRCDIR;
	chomp @files;
	@files = sort @files;
	if (@files == 0) {
		print RED; print ("Error:\tNo package found in '$inputdir/$rpms/$rhrelease' folder!!\n");
		exit 2;
	}
	if ($all == 1) {
		# get all rpms:
		&splitall();
	} elsif ($all == 2) {
		# get all rpms from given package name:
		&splitall();
		$e = 0;
		for ($g = 0; $g < @rpms; $g++) {
			for $i (0 .. $#sorted) {
				if ($sorted[$i][0] =~ /^$rpms[$g]$/) {
					for ($j = 0; $j <= $#{$sorted[$i]}; $j++) {
						$tmp[$e][$j] = $sorted[$i][$j];
					}
					$e++;
				}
			}
		}
		@sorted = @tmp;
	} else {
		# get newest rpms:
		&splitnewestrpm();
	}
	if (@sorted == 0) {
		print RED; print ("Error:\tGiven Redhat release does not match with release of package in '$inputdir/$rpms/$rhrelease' folder,\n\tplease use '-r <redhat release>' option!!\n");
		exit 2;
	}
	# push RPMs:
	for $i (0 .. $#sorted) {
		for $j (0 .. $#{$sorted[$i]}) {
			if ($j == 0) {
				$file = $sorted[$i][$j];
			} elsif ($j == 1) {
				$ver = $sorted[$i][$j];
			} elsif ($j == 2) {
				$rel = $sorted[$i][$j];
			} elsif ($j == 3) {
				$arch = $sorted[$i][$j];
			}
		}
		&selectchannel();
		# copy rpm to signdir:
		$fi = "$inputdir/$rpms/$rhrelease/$file-$ver-$rel.$arch.rpm";
		$fo = "$signdir/$rpms/$rhrelease/$channel/$file-$ver-$rel.$arch.rpm";
		print CYAN; print ("=>\tCopy rpm $fi to $fo\n"); print RESET;
		if ($listing == 1) {
			print ("\tcp $fi $fo\n");
		} else {
			copy ("$fi", "$fo") or die ("Could not copy '$fi' to '$fo': $!\n");
		}
		# sign the package:
		print CYAN; print ("=>\tSign rpm '$fo'\n"); print RESET;
		if ($listing == 1) {
			print ("\t$rpm --resign $fo\n");
		} else {
			$rc = 0xffff & system ("$rpm", "--resign", "$fo");
			if ($rc == 0) {
				print GREEN; print("=>\tDone.\n"); print RESET;
			} elsif (($rc & 0xff) == 0) {
				print RED; print("PGP rpm package sign failed!!\n"); print RESET;
			}
		}
		# push the package:
		print CYAN; print ("=>\tPushing rpm, $fo into satellite database. Channel: $channel\n"); print RESET;
		if ($listing == 1) {
			print ("\t$rhnpush -c$channel $opts -u$login -p$password --server=$server $fo\n");
		} else {
			@args = ("$rhnpush", "-c$channel", "$opts", "-u$login", "-p$password", "--server=$server", "$fo");
			#print ("**INFO**\t@args\n");
			$rc = 0xffff & system ("@args");
			if ($rc == 0) {
				print GREEN; print("=>\tDone.\n"); print RESET;
				&cleanup();
			} elsif (($rc & 0xff) == 0) {
				print RED; print("=>\tPushing rpm failed!!\n"); print RESET;
			}
		}
	}
	@sorted = ();
	## srpms:
	opendir(SRCDIR, "$inputdir/$srpms");
	@files = readdir SRCDIR;
	chomp @files;
	@files = sort @files;
	if (@files == 0) {
		print RED; print ("Error:\tNo package found in '$inputdir/$rpms/$rhrelease' folder!!\n");
		exit 2;
	}
	# get newest rpms:
	&splitnewestrpm();
	# push SRPMs:
	print ("\n=>\tSRPMs:\n");
	for $i (0 .. $#sorted) {
		for $j (0 .. $#{$sorted[$i]}) {
			if ($j == 0) {
				$file = $sorted[$i][$j];
			} elsif ($j == 1) {
				$ver = $sorted[$i][$j];
			} elsif ($j == 2) {
				$rel = $sorted[$i][$j];
			} elsif ($j == 3) {
				$arch = $sorted[$i][$j];
			}
		}
		# ignore php source rpm, it doesn't exist!
		if ($file eq "php") {
		} else {
			&selectchannel();
			# copy rpm to signdir:
			$fi = "$inputdir/$srpms/$file-$ver-$rel.$arch.rpm";
			$fo = "$signdir/$srpms/$channel/$file-$ver-$rel.$arch.rpm";
			print CYAN; print ("=>\tCopy srpm '$fi' to '$fo'\n"); print RESET;
			if ($listing == 1) {
				print ("\tcp $fi $fo\n");
			} else {
				copy ("$fi", "$fo") or die ("Could not copy '$fi' to '$fo': $!\n");
			}
			# sign the package:
			print CYAN; print ("=>\tSign srpm '$fo'\n"); print RESET;
			if ($listing == 1) {
				print ("\t$rpm --resign $fo\n");
			} else {
				$rc = 0xffff & system ("$rpm", "--resign", "$fo");
				if ($rc == 0) {
					print GREEN; print("=>\tDone.\n"); print RESET;
				} elsif (($rc & 0xff) == 0) {
					print RED; print("PGP rpm package sign failed!!\n"); print RESET;
				}
			}
			# push the package:
			print CYAN; print ("=>\tPushing srpm, $fo into satellite database. Channel: $channel\n"); print RESET;
			if ($listing == 1) {
				print ("\t$rhnpush -c$channel --source $opts -u$login -p$password --server=$server $fo\n");
			} else {
				@args = ("$rhnpush", "-c$channel", "--source", "$opts", "-u$login", "-p$password", "--server=$server", "$fo");
				#print ("**INFO**\t@args\n");
				$rc = 0xffff & system ("@args");
				if ($rc == 0) {
					print GREEN; print("=>\tDone.\n"); print RESET;
					&cleanup();
				} elsif (($rc & 0xff) == 0) {
					print RED; print("=>\tPushing rpm failed!!\n"); print RESET;
				}
			}
		}
	}
}

## empty successfull laoded rpms:
sub cleanup() {
	if ($cleanup == 1) {
		if (-f $fo) {
			unlink ("$fo");
		}
	}
}
## list the newes available and the latest already pushed package:
sub compare() {
	my $f = "";
	my $i = 0;
	my $j = 0;
	my $m = 0;
	my @newtopushv = ();
	my @newtopushr = ();
	my @newtopushf = ();
	my @alreadypushedv = ();
	my @alreadypushedr = ();
	my @alreadypushedf = ();
	my @alreadypusheda = ();
	my @alreadypushedc = ();
	my @tmp = ();
	my @ap = ();
	@files = ();
	for $rel (@releases) {
		opendir(SRCDIR, "$inputdir/$rpms/$rel");
		@tmp = readdir SRCDIR;
		chomp @tmp;
		@tmp = sort @tmp;
		if (@files == 0) {
			@files = @tmp;
		} else {
			@files = (@files, @tmp);
		}
	}
	&splitnewestrpm();
	for $i (0 .. $#sorted) {
		for $j (0 .. $#{$sorted[$i]}) {
			if ($j == 0) {
				$file = $sorted[$i][$j];
			} elsif ($j == 1) {
				$ver = $sorted[$i][$j];
			} elsif ($j == 2) {
				$rel = $sorted[$i][$j];
			}
		}
		#$newtopush[$i] = ("$file;$ver;$arch;$rel");
		$newtopushv[$i] = $ver;
		$newtopushr[$i] = $rel;
		$newtopushf[$i] = $file;
	}
	### Get list of already pushed packages from satellite server:
	$i = 0;
	foreach $channel (@channels) {
		@ap = `$rhnpush -l -c$channel -u$login -p$password --server=$server`;
		foreach (@ap) {
			#print ("$channel: $_\n");
			if ($_ =~ /^\[/) {
				@tmp = split (/\s+/, $_);
				$alreadypushedv[$i] = $tmp[1];
				$alreadypushedr[$i] = $tmp[2];
				$alreadypushedf[$i] = $tmp[0];
				$alreadypusheda[$i] = $tmp[4];
				$alreadypushedc[$i] = $tmp[5];
				$alreadypushedv[$i] =~ s/\[//g;
				$alreadypushedv[$i] =~ s/\'//g;
				$alreadypushedv[$i] =~ s/\,//g;
				$alreadypushedr[$i] =~ s/\[//g;
				$alreadypushedr[$i] =~ s/\'//g;
				$alreadypushedr[$i] =~ s/\,//g;
				$alreadypushedf[$i] =~ s/\[//g;
				$alreadypushedf[$i] =~ s/\'//g;
				$alreadypushedf[$i] =~ s/\,//g;
				$alreadypusheda[$i] =~ s/\[//g;
				$alreadypusheda[$i] =~ s/\'//g;
				$alreadypusheda[$i] =~ s/\,//g;
				$alreadypushedc[$i] =~ s/\]//g;
				$alreadypushedc[$i] =~ s/\'//g;
				$alreadypushedc[$i] =~ s/\,//g;
				#print ("Name: $alreadypushedf[$i], Version: $alreadypushedv[$i], Revision: $alreadypushedr[$i], Arch: $alreadypusheda[$i]\n");
				$i++;
			}
		}
	}
	print ("\n===>\tListing:\n");
	print ("========================================================================================================================================\n");
	print (" Comparison list off already pushed and newest RPM packages (already pushed: first line!)\n");
	print GREEN; print ("  Green:\tLatest available packages has the same status like the already pushed package.\n");
	print YELLOW; print ("  Yellow:\tRelease is a newer version available, but version is the same.\n");
	print CYAN; print ("  Cyan:\t\tDifferent version and newer release available to push.\n");
	print RED; print ("  Red:\t\tNone of above is matching.\n");
	print RESET;
	print ("-----------------------------------------------|---------------------------|---------------|----------------|---------------------------\n");
	print ("");
	#print:
	for ($i = 0; $i < @newtopushf; $i++) {
		for ($j = 0; $j < @alreadypushedf; $j++) {
			if ($alreadypushedf[$j] eq $newtopushf[$i]) {
				if (($alreadypushedr[$j] eq $newtopushr[$i]) and ($alreadypushedv[$j] eq $newtopushv[$i])) {
					printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | Already pushed | Channel: %-15s\n", $alreadypushedf[$j], $alreadypushedv[$j], $alreadypushedr[$j], $alreadypushedc[$j]);
					print GREEN; printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | available      | \n", $newtopushf[$i], $newtopushv[$i], $newtopushr[$i]); print RESET;
				} elsif (($alreadypushedr[$j] < $newtopushr[$i]) and ($alreadypushedv[$j] eq $newtopushv[$i])) {
					printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | Already pushed | Channel: %-15s\n", $alreadypushedf[$j], $alreadypushedv[$j], $alreadypushedr[$j], $alreadypushedc[$j]);
					print YELLOW; printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | available      | \n", $newtopushf[$i], $newtopushv[$i], $newtopushr[$i]); print RESET;
				} elsif (($alreadypushedr[$j] < $newtopushr[$i]) and ($alreadypushedv[$j] ne $newtopushv[$i])) {
					printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | Already pushed | Channel: %-15s\n", $alreadypushedf[$j], $alreadypushedv[$j], $alreadypushedr[$j], $alreadypushedc[$j]);
					print CYAN; printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | available      | \n", $newtopushf[$i], $newtopushv[$i], $newtopushr[$i]); print RESET;
				} else {
					printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | Already pushed | Channel: %-15s\n", $alreadypushedf[$j], $alreadypushedv[$j], $alreadypushedr[$j], $alreadypushedc[$j]);
					print RED; printf ("Package:  %-36s | Version:  %-15s | Release:  %-3s | available      | \n", $newtopushf[$i], $newtopushv[$i], $newtopushr[$i]); print RESET;
				}
				print ("-----------------------------------------------|---------------------------|---------------|----------------|---------------------------\n");
			}
		}
	}
	print ("========================================================================================================================================\n");
	print ("Note:\tIf not all packages where pushed before, the above list is not complete with all available packages\n\tTo show a complete list, use $0 -l!!\n");
}
### main:
# check command line options:
&args();
# list options:
#print ("\nRPMs: @rpms, OUT: $signdir, IN: $inputdir, CHANNEL: @chan, LOGIN: $login, PASSWORD: $password, OPTS: @opts, LISTING: $listing Lastonly: $lastonly, Compare: $compare\n");
#exit;
# check for listing argument (-l):
if ($list == 1) {
	&showlist();
	exit 0;
}
# check for previous listing argument (-p):
if ($previous == 1) {
	&listprevious();
	exit 0;
} elsif ($compare == 1) {
	&compare();
	exit 0;
}
# check for proper user:
&checkuser();
# select proper channel:
&checkchannel();
&checkdirs();
# push the RPMs into satellite db:
&pushrpms();

### cleanup:
print ("\n\n");
