package Apache::TestDirectives;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use DynaLoader (); 
use Apache::Constants qw(DECLINE_CMD);

eval {
  require Apache::ModuleConfig;
};
use Data::Dumper 'Dumper';

@ISA = qw(DynaLoader TestDirectives::Base);

$VERSION = '0.01';

if($ENV{MOD_PERL}) {
    bootstrap Apache::TestDirectives $VERSION;
}

sub attr {
    my($self,$k,$v) = @_;
    $self->{$k} = $v;
}

sub Port ($$$) {
    my($cfg, $parms, $port) = @_;
    warn "$cfg->Port will be $port\n";
    $cfg->{Port} = $port;
    return DECLINE_CMD();
}

sub TestCmd ($$$$) {
    my($cfg, $parms, $one, $two) = @_;
    #warn "TestCmd called with args: `$one', `$two'\n";
    $cfg->attr(TestCmd => [$one,$two]);
    $parms->server->isa("Apache::Server") or die "parms->server busted";
    my $or = $parms->override;
    my $limit = $parms->limited;
    #warn Dumper($cfg), $/;
}

sub AnotherCmd () {
    die "prototype check broken [@_]" if @_ > 0;
}

sub CmdIterate ($$@) {
    my($cfg, $parms, @data) = @_;
    $cfg->{CmdIterate} = [@data];
    $cfg->{path} = $parms->path;
}

sub another_cmd {
    my($cfg, $parms, @data) = @_;
    warn "($cfg, $parms, @data)\n";
    $parms->info =~ /YAC/ or die "parms->info busted";
    $cfg->{parms_info_from_another_cmd} = $parms->info;
    warn "$cfg->YAC called\n";
}

sub Container ($$$;*) {
    my($cfg, $parms, $arg, $fh) = @_;
    $arg =~ s/>//;
    warn "ARG=$arg\n";
    #while($parms->getline($line)) {
    while(defined(my $line = <$fh>)) {
	last if $line =~ m:</Container>:i;
	warn "LINE=`$line'\n";
    }
}

sub Container_END () {
    die "</Container> outside a <Container>\n";
}

use Apache::ExtUtils ();
my $proto_perl2c = Apache::ExtUtils->proto_perl2c;

my $code = "";
while(my($pp,$cp) = each %$proto_perl2c) {
    next unless $pp;
    $code .= <<SUB;
sub $cp ($pp) { 
    warn "$cp called with args: ", (map "`\$_', ", \@_), "\n";
    my(\$cfg, \$parms, \@args) = \@_;
    \$cfg->attr($cp => [\@args]) if ref(\$cfg);
}
SUB
}

eval $code; die $@ if $@;

package TestDirectives::Base;

sub DIR_CREATE {
    my($class, $parms) = @_;
    my $info = $parms->info;
    my $o = $parms->override;
    warn "$class->new called info=`$info',override=`$o'\n";
    return bless {
	FromNew => __PACKAGE__,
	path => $parms->path || "",
    }, $class;
}

sub DIR_MERGE {
    my($base, $add) = @_;
    my %new = ();
    @new{ keys %$base, keys %$add} = 
	(values %$base, values %$add);

    return bless \%new, ref($base);
}

*SERVER_MERGE = \&DIR_MERGE;

sub SERVER_CREATE {
    my($class, $parms) = @_;
    warn "$class->SERVER_CREATE\n";
    return bless {
	ServerClass => __PACKAGE__,
    }, $class;
}
 
1;
__END__
