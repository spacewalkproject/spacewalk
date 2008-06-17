package Apache::Opcode;

use strict;

my $Mask = read_opmask(\*DATA);

sub __NOTYET__handler {
    my $r = shift;
    my $mask;
    if(my $opcodes = $r->dir_config("Opcodes")) {
	my $file = $r->server_root_relative($opcodes);
	if(-e $file) {
	    $mask = $file;
	}
	else {
	    my @opnames = split /\s+/, $opcodes;
	    $mask = \@opnames;
	}
    }
    else {
	$mask = \$Mask;
    }
    return -1; #DECLINED
}

sub read_opmask {
    require Opcode;
    my $fh = shift;
    my $mask;
    while (<$fh>) {
	chomp;
	s/^\s+//;s/\s+$//;
	s/^#.*//;
	next unless /\w+/; 
	#warn "adding $_\n";
	$mask |= Opcode::opset($_);
    }
    return $mask;
}

sub gen_op_mask {
    require MIME::Base64;
    my $mask;
    if(@ARGV) {
	local *FH;
	open FH, $ARGV[0] or die "can't open $ARGV[0] $!";  
	$mask = read_opmask(\*FH);
	close FH;
    }
    else {
	$mask = $Mask;
    }
    printf qq{
static char *MP_op_mask = "%s";
}, MIME::Base64::encode($mask);
}

1;

__DATA__
backtick
glob
open
close
pipe_op
fileno
umask
dbmopen
dbmclose
getc
read
enterwrite
leavewrite
sysopen
sysseek
sysread
syswrite
send
recv
socket
sockpair
bind
connect
listen
accept
shutdown
chown
chroot
unlink
chmod
rename
link
symlink
readlink
mkdir
rmdir
open_dir
readdir
telldir
seekdir
rewinddir
closedir
fork
wait
waitpid
system
exec
kill
alarm
sleep
shmget
shmctl
shmread
shmwrite
msgget
msgctl
msgsnd
msgrcv
semget
semctl
semop
syscall
