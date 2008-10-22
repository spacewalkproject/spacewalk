#!/usr/bin/perl

package CommandServer;
use NOCpulse::SpreadServers;
use NOCpulse::PlugFrame::LocalCommandShell;
use Data::Dumper;
@ISA=qw(SpreadServer);

sub processMessage {
	my ($self,$message) = @_;
	my $contents = $message->get_contents;
	print Dumper($message);
	my $command = NOCpulse::PlugFrame::LocalCommandShell->newInitialized;
	if ( $contents =~ /^\|/ ) {
		$contents =~ s/^.//;
		my ($keyword,$value) = split(' ',$contents,2);
		if ($keyword eq 'timeout') {
			$command->set_timeout($value);
			$command->set_stdout("OK, timeout is $value");
			$command->set_stderr('');
			$command->set_exit(0);
		} else {
			$command->set_stdout("ERROR, unknown command $keyword");
			$command->set_stderr('');
			$command->set_exit(1);
		}
	} else {
		$command->set_probeCommands($message->get_contents);
		$command->execute;
	}
	my $reply = SpreadObjectMessage->newInitialized({
				addressee=>$message->get_sender
			});
	$reply->addInstVar('stdout',$command->get_stdout);
	$reply->addInstVar('stderr',$command->get_stderr);
	$reply->addInstVar('exit',$command->get_exit);
	$reply->sendVia($self->replyConnection);
}
#####################################################################

package main;
my $server = CommandServer->newInitialized({
						groups=>['cmdserv'],
						privateName=>'cmdservr',
					});
$server->processEvents;
