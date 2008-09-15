#!/usr/bin/perl
use NOCpulse::Object;
use GDBM_File;
use NOCpulse::Config;
use IO::Dir;

$config = NOCpulse::Config->new;

Object::SystemIni($config->get('PlugFrame','configFile'));

# Purge old current state and probe state files.
my $targetDatabaseDir=$Object::config->val('Probe','databaseDirectory');
my $inputDbm = $targetDatabaseDir.'/Probe.db'; # WARNING - HARD EXTENSION HERE!
my $tries = 0;
my $maxtries = 500;
 
my %database;
#print "input dbm is $inputDbm\n"; 
while (!  tie(%database, 'GDBM_File', $inputDbm, &GDBM_WRCREAT, 0640)) {
        if ("$!" ne "Resource temporarily unavailable") {
                $tries = $tries + 1;
                if ($tries >= $maxtries) {
                        print "ERROR: $filename - $!\n";exit -1;
                }
        }
        sleep(1);
}
my $rmcount = 0;
my $oldId;
my $curStateDir = $Object::config->val('ProbeState','databaseDirectory');
#print "dir is $curStateDir\n";
my %dir;
tie %dir, IO::Dir, $curStateDir;
my @oldProbeIds = grep(s/(?:ProbeState|state).(\d+)/$1/,keys(%dir));
untie %dir;
foreach $oldId (@oldProbeIds) {
	#print "Checking $oldId\n";
        if (! exists($database{$oldId})) {
                # Have to nuke old files
		#print "Removing $oldId\n";
                if (unlink($curStateDir."/ProbeState.$oldId") == 0) {
                    unlink($curStateDir."/state.$oldId");
                }
                $rmcount ++;
        }
}
if ($rmcount) {
        print "Removed $rmcount obsolete probe(s)\n";
} else {
	print "All current state files are valid - nothing to do\n";
}
untie(%database);
