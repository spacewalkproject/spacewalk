package Apache::Status;
use strict;

$Apache::Status::VERSION = '2.02';

my %is_installed = ();
my $Is_Win32 = ($^O eq "MSWin32");
{
    local $SIG{__DIE__};
    %is_installed = map {
	$_, (eval("require $_") || 0);
    } qw (Data::Dumper Devel::Symdump B Apache::Request Apache::Peek Apache::Symbol);
}

use vars qw($newQ);

if ($is_installed{"Apache::Request"}) {
    $newQ ||= sub { Apache::Request->new(@_) };
}
else {
    $is_installed{"CGI"} = eval("require CGI") || 0;
    $newQ ||= sub { CGI->new; };
}

my $CPAN_base = "http://www.perl.com/CPAN/modules/by-module";

my(%status) = (
   script => "PerlRequire'd Files",
   inc => "Loaded Modules",
   rgysubs => "Compiled Registry Scripts",
   'symdump' => "Symbol Table Dump",
   inh_tree => "Inheritance Tree",
   isa_tree => "ISA Tree",	       
   env => "Environment",
   sig => "Signal Handlers",	       
   myconfig => "Perl Configuration",	       
   hooks => "Enabled mod_perl Hooks",
);

delete $status{'sig'} if $Is_Win32;

if($Apache::Server::SaveConfig) {
    $status{"section_config"} = "Perl Section Configuration";
}

sub menu_item {
    my($self, $key, $val, $sub) = @_;
    $status{$key} = $val;
    no strict;
    *{"status_${key}"} = $sub 
	if $sub and ref $sub eq 'CODE';
}

sub handler {
    my($r) = @_;
    Apache->request($r); #for Apache::CGI
    my $qs = $r->args || "";
    my $sub = "status_$qs";
    no strict 'refs';

    if($qs =~ s/^(noh_\w+).*/$1/) {
	return &{$qs}($r, $newQ->($r));
    }

    header($r);
    if(defined &$sub) {
	$r->print(@{ &{$sub}($r, $newQ->($r)) });
    }
    elsif ($qs and %{$qs."::"}) {
	$r->print(symdump($r, $newQ->($r), $qs));
    }
    else {
	my $uri = $r->uri;
	$r->print(
 	    map { qq[<a href="$uri?$_">$status{$_}</a><br>\n] } keys %status
        );
    }
    $r->print("</body></html>");

    1;
}

sub header {
    my $r = shift;
    my $start = scalar localtime $^T;    
    my $srv = Apache::Constants::SERVER_VERSION();
    $r->send_http_header("text/html");
    my $v = $^V ? sprintf "v%vd", $^V : $];
    $r->print(<<"EOF");
<html>
<head><title>Apache::Status</title></head>
<body>
Embedded Perl version <b>$v</b> for <b>$srv</b> process <b>$$</b>, 
<br> running since $start<hr>
EOF

}

sub symdump {
    my($r, $q, $package) = @_;
    unless ($is_installed{"Devel::Symdump"}) {
	return <<EOF;
Please install the <a href="$CPAN_base/Devel/">Devel::Symdump</a> module.
EOF
    }
    my $meth = "new";
    $meth = "rnew" if lc($r->dir_config("StatusRdump")) eq "on";
    my $sob = Devel::Symdump->$meth($package);
    return $sob->Apache::Status::as_HTML($package, $r, $q);
}

sub status_symdump { 
    my($r,$q) = @_;
    [symdump($r, $q, 'main')];
}

sub status_section_config {
    my($r,$q) = @_;
    require Apache::PerlSections;
    ["<pre>", Apache::PerlSections->dump, "</pre>"];
}

sub status_hooks {
    my($r,$q) = @_;
    require mod_perl;
    require mod_perl_hooks;
    my @retval = qw(<table>);
    my @list = mod_perl::hooks();
    for my $hook (sort @list) {
	my $on_off = 
	  mod_perl::hook($hook) ? "<b>Enabled</b>" : "<i>Disabled</i>";
	push @retval, "<tr><td>$hook</td><td>$on_off</td></tr>\n";
    }
    push @retval, qw(</table>);
    \@retval;
}

sub status_inc {
    my($r,$q) = @_;
    my(@retval, $module, $v, $file);
    my $uri = $r->uri;
    push @retval, "<table border=1>";
    push @retval, 
    "<tr>", 
    (map "<td><b>$_</b></td>", qw(Package Version Modified File)),
    "</tr>\n";

    foreach $file (sort keys %INC) {
	local $^W = 0;
	next if $file =~ m:^/:;
	next unless $file =~ m:\.pm:;
	next unless $INC{$file}; #e.g. fake Apache/TieHandle.pm
	no strict 'refs';
	($module = $file) =~ s,/,::,g;
	$module =~ s,\.pm$,,;
	$v = ${"$module\:\:VERSION"} || '0.00';
	push @retval, 
        "<tr>", 
        (map "<td>$_</td>", 
	 qq(<a href="$uri?$module">$module</a>),
	 $v, scalar localtime((stat $INC{$file})[9]), $INC{$file}),
        "</tr>\n";
    }
    push @retval, "</table>\n";
    push @retval, "<p><b>\@INC</b> = <br>", join "<br>\n", @INC, "";
    \@retval;
}

sub status_script {
    my($r,$q) = @_;
    my(@retval, $file);
    push @retval, "<table border=1>";
    push @retval, "<tr><td><b>PerlRequire</b></td><td><b>Location</b></td></tr>\n";
    foreach $file (sort keys %INC) {
	next if $file =~ m:\.(pm|al|ix)$:;
	push @retval, 
	qq(<tr><td>$file</td><td>$INC{$file}</td></tr>\n);
    }
    push @retval, "</table>";
    \@retval;
}

sub status_rgysubs {
    my($r,$q) = @_;
    my(@retval);
    local $_;
    my $uri = $r->uri;
    push @retval, "<b>Click on package name to see its symbol table</b><p>\n";
    foreach (sort keys %{$Apache::Registry}) {
	push @retval, 
	qq(<a href="$uri?$_">$_</a>\n),
	"<br>";
    }
    \@retval;
}

sub status_env { 
    ["<pre>", 
     (map { "$_ = $ENV{$_}\n" } sort keys %ENV), 
     "</pre>"];
}

sub status_sig { 
    ["<pre>", 
     (map { 
	 my $val = $SIG{$_} || "";
	 if($val and ref $val eq "CODE") {
	     if(my $cv = Apache::Symbol->can('sv_name')) {
		 $val = "\\&".  $cv->($val);
	     }
	 }
	 "$_ = $val\n" }
      sort keys %SIG), 
     "</pre>"];
}

sub status_myconfig {
    require Config;
    ["<pre>", Config::myconfig(), "</pre>"]
}

sub status_inh_tree { ["<pre>", Devel::Symdump->inh_tree, "</pre>"] }
sub status_isa_tree { ["<pre>", Devel::Symdump->isa_tree, "</pre>"] }

sub status_data_dump { 
    my($r,$q) = @_;
    my($name,$type) = (split "/", $r->uri)[-2,-1];
    my $script = $q->script_name;
    no strict 'refs';
    my @retval;
    push @retval, "Data Dump of $name $type <pre>\n";
    my $str = Data::Dumper->Dump([*$name{$type}], ['*'.$name]);
    $str =~ s/= \\/= /; #whack backwack
    push @retval, $str, "\n";
    push @retval, peek_link($r, $q, $name, $type);
    push @retval, b_graph_link($r, $q, $name);
    push @retval, "</pre>";
    \@retval;
}

sub cv_file {
    my $obj = shift;
    $obj->can('FILEGV') ? $obj->FILEGV->SV->PV : $obj->FILE;
}

sub status_cv_dump { 
    my($r,$q) = @_;
    return [] unless $is_installed{B};

    no strict 'refs';

    my($name,$type) = (split "/", $r->uri)[-2,-1];
    my @retval = "Subroutine info for <b>$name</b> <pre>\n";
    my $script = $q->script_name;
    my $obj    = B::svref_2object(*$name{CODE});
    my $file   = cv_file($obj);
    my $stash  = $obj->GV->STASH->NAME;

    push @retval, "File: ", 
    (-e $file ? qq(<a href="file:$file">$file</a>) : $file), "\n";

    my $cv    = $obj->GV->CV;
    my $proto = $cv->PV if $cv->can('PV');
    push @retval, 
    qq(Package: <a href="$script?$stash">$stash</a>\n);
    push @retval, "Line: ",      $obj->GV->LINE, "\n";
    push @retval, "Prototype: ", $proto || "none", "\n";
    push @retval, "XSUB: ",      $obj->XSUB ? "yes" : "no", "\n";
    push @retval, peek_link($r, $q, $name, $type);
    #push @retval, xref_link($r, $q, $name);
    push @retval, b_graph_link($r, $q, $name);
    push @retval, b_lexinfo_link($r, $q, $name);
    push @retval, b_terse_link($r, $q, $name);
    push @retval, b_terse_size_link($r, $q, $name);
    push @retval, b_deparse_link($r, $q, $name);
    push @retval, b_fathom_link($r, $q, $name);
    push @retval, "</pre>";
    \@retval;
}

sub status_config {
    my($r, $key) = @_;
    return (lc($r->dir_config($key)) eq "on") ||
      (lc($r->dir_config('StatusOptionsAll')) eq "on");
}

sub b_graph_link {
    my($r,$q,$name) = @_;
    return unless status_config($r, "StatusGraph");
    return unless eval { require B::Graph };
    B::Graph->UNIVERSAL::VERSION('0.03');
    my $script = $q->script_name;
    return qq(\n<a href="$script/$name?noh_b_graph">OP Tree Graph</a>\n);
}

sub b_lexinfo_link {
    my($r, $q, $name) = @_;
    return unless status_config($r, "StatusLexInfo");
    return unless eval { require B::LexInfo };
    my $script = $q->script_name;
    return qq(\n<a href="$script/$name?noh_b_lexinfo">Lexical Info</a>\n);
}

sub noh_b_lexinfo {
    my $r = shift;
    $r->send_http_header("text/plain");
    no strict 'refs';
    my($name) = (split "/", $r->uri)[-1];
    $r->print("Lexical Info for $name\n\n");
    my $lexi = B::LexInfo->new;
    my $info = $lexi->cvlexinfo($name);
    print ${ $lexi->dumper($info) };
}

my %b_terse_exp = ('slow' => 'syntax', 'exec' => 'execution');

sub b_terse_link {
    my($r, $q, $name) = @_;
    return unless status_config($r, "StatusTerse");
    return unless eval { require B::Terse };
    my $script = $q->script_name;
    my @retval;
    for (qw(exec slow)) {
	my $exp = "$b_terse_exp{$_} order";
	push @retval,
	qq(\n<a href="$script/$_/$name?noh_b_terse">Syntax Tree Dump ($exp)</a>\n);
    }
    join '', @retval;
}

sub noh_b_terse {
    my $r = shift;
    $r->send_http_header("text/plain");
    no strict 'refs';
    my($arg, $name) = (split "/", $r->uri)[-2,-1];
    $r->print("Syntax Tree Dump ($b_terse_exp{$arg}) for $name\n\n");
    B::Terse::compile($arg, $name)->();
}

sub b_terse_size_link {
    my($r, $q, $name) = @_;
    return unless status_config($r, "StatusTerseSize");
    return unless eval { require B::TerseSize };
    my $script = $q->script_name;
    my @retval;
    for (qw(exec slow)) {
	my $exp = "$b_terse_exp{$_} order";
	push @retval,
	qq(\n<a href="$script/$_/$name?noh_b_terse_size">Syntax Tree Size ($exp)</a>\n);
    }
    join '', @retval;
}

sub noh_b_terse_size {
    my $r = shift;
    $r->send_http_header("text/html");
    $r->print('<pre>');
    my($arg, $name) = (split "/", $r->uri)[-2,-1];
    my $uri = $r->location;
    my $link = qq{<a href="$uri/$name/CODE?cv_dump">$name</a>};
    $r->print("Syntax Tree Size ($b_terse_exp{$arg} order) for $link\n\n");
    B::TerseSize::compile($arg, $name)->();
}

sub b_package_size_link {
    my($r, $q, $name) = @_;
    return unless status_config($r, "StatusPackageSize");
    return unless eval { require B::TerseSize };
    my $script = $q->script_name;
    qq(<a href="$script/$name?noh_b_package_size">Memory Usage</a>\n);
}

sub noh_b_package_size {
    my($r, $q) = @_;
    $r->send_http_header("text/html");
    $r->print('<pre>');
    no strict 'refs';
    my($package) = (split "/", $r->uri)[-1];
    my $script = $q->script_name;
    $r->print("Memory Usage for package $package\n\n");
    my($subs, $opcount, $opsize) = B::TerseSize::package_size($package);
    $r->print("Totals: $opsize bytes | $opcount OPs\n\n");
    my($clen, $slen, $nlen);
    my @keys = map {
	$nlen = length > $nlen ? length : $nlen;
	$_;
    } (sort { $subs->{$b}->{size} <=> $subs->{$a}->{size} } keys %$subs);

    $clen = length $subs->{$keys[0]}->{count};
    $slen = length $subs->{$keys[0]}->{size};

    for my $name (@keys) {
	my $stats = $subs->{$name};
	if ($name =~ /^my /) {
	    printf "%-${nlen}s %${slen}d bytes\n", $name, $stats->{size};
	}
	elsif ($name =~ /^\*(\w+)\{(\w+)\}/) {
	    my $link = qq(<a href="$script/$package\::$1/$2?data_dump">);
	    printf "$link%-${nlen}s</a> %${slen}d bytes\n", $name, $stats->{size};
	}
	else {
	    my $link = 
	      qq(<a href="$script/slow/$package\::$name?noh_b_terse_size">);
	    printf "$link%-${nlen}s</a> %${slen}d bytes | %${clen}d OPs\n",
	    $name, $stats->{size}, $stats->{count};
	}
    }
}

sub b_deparse_link {
    my($r, $q, $name) = @_;
    return unless status_config($r, "StatusDeparse");
    return unless eval { require B::Deparse };
    return unless $B::Deparse::VERSION >= 0.59;
    my $script = $q->script_name;
    return qq(\n<a href="$script/$name?noh_b_deparse">Deparse</a>\n);
}

sub noh_b_deparse {
    my $r = shift;
    $r->send_http_header("text/plain");
    my $name = (split "/", $r->uri)[-1];
    $r->print("Deparse of $name\n\n");
    my $deparse = B::Deparse->new(split /\s+/, 
				  $r->dir_config('StatusDeparseOptions')||"");
    my $body = $deparse->coderef2text(\&{$name});
    $r->print("sub $name $body");
}

sub b_fathom_link {
    my($r, $q, $name) = @_;
    return unless status_config($r, "StatusFathom");
    return unless eval { require B::Fathom };
    return unless $B::Fathom::VERSION >= 0.05;
    my $script = $q->script_name;
    return qq(\n<a href="$script/$name?noh_b_fathom">Fathom Score</a>\n);
}

sub noh_b_fathom {
    my $r = shift;
    $r->send_http_header("text/plain");
    my $name = (split "/", $r->uri)[-1];
    $r->print("Fathom Score of $name\n\n");
    my $fathom = B::Fathom->new(split /\s+/, 
				$r->dir_config('StatusFathomOptions')||"");
    $r->print($fathom->fathom(\&{$name}));
}

sub peek_link {
    my($r,$q,$name,$type) = @_;
    return unless status_config($r, "StatusPeek");
    return unless $is_installed{"Apache::Peek"};
    my $script = $q->script_name;
    return qq(\n<a href="$script/$name/$type?noh_peek">Peek Dump</a>\n);
}

sub noh_peek {
    my $r = shift;
    $r->send_http_header("text/plain");
    no strict 'refs';
    my($name,$type) = (split "/", $r->uri)[-2,-1];
    $type =~ s/^FUNCTION$/CODE/;
    $r->print("Peek Dump of $name $type\n\n");
    Apache::Peek::Dump(*{$name}{$type});
}

sub xref_link {
    my($r,$q,$name) = @_;
    my $script = $q->script_name;
    return unless $is_installed{"B::Xref"};
    return qq(\n<a href="$script/$name?noh_xref">Cross Reference Report</a>\n);
}

sub noh_xref {
    my $r = shift;
    require B::Xref;
    (my $thing = $r->path_info) =~ s:^/::;
    $r->send_http_header("text/plain");
    print "Xref of $thing\n";
    B::Xref::compile($thing)->();
}

$Apache::Status::BGraphCache ||= 0;
if ($Apache::Status::BGraphCache) {
    Apache->push_handlers(PerlChildExitHandler => sub {
			      unlink keys %Apache::Status::BGraphCache;
			  });
}

sub noh_b_graph {
    my $r = shift;
    require B::Graph;

    untie *STDOUT;
    
    my $dir = $r->server_root_relative(
                   $r->dir_config("GraphDir") || "logs/b_graphs");

    mkdir $dir, 0755 unless -d $dir;

    (my $thing = $r->path_info) =~ s:^/::;
    my $type = "dot";
    my $file = "$dir/$thing.$$.gif";
    
    unless (-e $file) {
	tie *STDOUT, "B::Graph", $r, $file;
	B::Graph::compile("-$type", $thing)->();
	(tied *STDOUT)->{graph}->close;
    }

    if(-s $file) {
	local *FH;
	open FH, $file or
	    die "can't open $file $!";
	$r->send_http_header("image/gif");
	$r->send_fd(\*FH);
    }
    else {
	$r->send_http_header("text/plain");
	$r->print("Graph of $thing failed!\n");
    }
    if ($Apache::Status::BGraphCache) {
	$Apache::Status::BGraphCache{$file}++;
    }
    else {
	unlink $file;
    }

    0;
}

sub B::Graph::TIEHANDLE {
    my($class, $r, $file) = @_;

    if ($file =~ /^([^<>|;]+)$/) {
	$file = $1;
    } 
    else {
	die "TAINTED data in THING=> ($file)";
    }

    $ENV{PATH} = join ":", qw{/usr/bin /usr/local/bin};
    my $dot = $r->dir_config("Dot") || "dot";

    my $pipe = IO::File->new("|$dot -Tgif -o $file");
    $pipe or die "can't open pipe to dot $!";
    $pipe->autoflush(1);

    return bless {
	graph => $pipe,
	r => $r,
    }, $class;
}

sub B::Graph::PRINT {
    my $self = shift;
    $self->{graph}->print(@_);
}

my %can_dump = map {$_,1} qw(scalars arrays hashes);

sub as_HTML {
    my($self, $package, $r, $q) = @_;
    my @m = qw(<TABLE>);
    my $uri = $r->uri;
    my $is_main = $package eq "main";

    my $do_dump = status_config($r, "StatusDumper");

    my @methods = sort keys %{$self->{'AUTOLOAD'}};

    if($is_main) { 
	@methods = grep { $_ ne "packages" } @methods;
	unshift @methods, "packages";
    }

    for my $type (@methods) {
	(my $dtype = uc $type) =~ s/E?S$//;
	push @m, "<TR><TD valign=top><B>$type</B></TD>";
	my @line = ();

	for (sort $self->_partdump(uc $type)) {
	    s/([\000-\037\177])/ '^' . pack('c', ord($1) ^ 64)/eg; 

	    if($type eq "scalars") {
		no strict 'refs';
		next unless defined eval { $$_ };
	    }

	    if($type eq "packages") {
		push @line, qq(<a href="$uri?$_">$_</a>);
	    }
	    elsif($type eq "functions") {
		if($is_installed{B}) {
		    push @line, qq(<a href="$uri/$_/$dtype?cv_dump">$_</a>);
		}
		else {
		    push @line, $_;
		}
	    }
	    elsif($do_dump and $can_dump{$type} and 
		  $is_installed{"Data::Dumper"}) {
		next if /_</;
		push @line, qq(<a href="$uri/$_/$dtype?data_dump">$_</a>);
	    }
	    else {
		push @line, $_;
	    }
	} 
	push @m, "<TD>" . join(", ", @line) . "</TD></TR>\n";
    }
    push @m, "</TABLE>";

    return join "\n", @m, "<hr>", b_package_size_link($r, $q, $package);
}

1;

__END__

=head1 NAME

Apache::Status - Embedded interpreter status information 

=head1 SYNOPSIS

 <Location /perl-status>
 SetHandler  perl-script
 PerlHandler Apache::Status
 </Location>

=head1 DESCRIPTION

The B<Apache::Status> module provides some information
about the status of the Perl interpreter embedded in the server.

Configure like so:

 <Location /perl-status>
 SetHandler  perl-script
 PerlHandler Apache::Status
 </Location>

Other modules can "plugin" a menu item like so:

 Apache::Status->menu_item(
    'DBI' => "DBI connections", #item for Apache::DBI module
    sub {
        my($r,$q) = @_; #request and CGI objects
        my(@strings);
        push @strings,  "blobs of html";
        return \@strings;     #return an array ref
    }
 ) if Apache->module("Apache::Status"); #only if Apache::Status is loaded

B<WARNING>: Apache::Status must be loaded before these modules via the 
PerlModule or PerlRequire directives.

=head1 OPTIONS

=over 4

=item StatusOptionsAll

This single directive will enable all of the options described below.

 PerlSetVar StatusOptionsAll On

=item StatusDumper

When browsing symbol tables, the values of arrays, hashes ans calars
can be viewed via B<Data::Dumper> if this configuration variable is set
to On:

 PerlSetVar StatusDumper On

=item StatusPeek

With this option On and the B<Apache::Peek> module installed, 
functions and variables can be viewed ala B<Devel::Peek> style:

 PerlSetVar StatusPeek On

=item StatusLexInfo

With this option On and the B<B::LexInfo> module installed,
subroutine lexical variable information can be viewed.

 PerlSetVar StatusLexInfo On

=item StatusDeparse

With this option On and B<B::Deparse> version 0.59 or higher 
(included in Perl 5.005_59+), subroutines can be "deparsed".

 PerlSetVar StatusDeparse On

Options can be passed to B::Deparse::new like so:

 PerlSetVar StatusDeparseOptions "-p -sC"

See the B<B::Deparse> manpage for details.

=item StatusTerse

With this option On, text-based op tree graphs of subroutines can be 
displayed, thanks to B<B::Terse>.

 PerlSetVar StatusTerse On

=item StatusTerseSize

With this option On and the B<B::TerseSize> module installed,
text-based op tree graphs of subroutines and their size can be
displayed.  See the B<B::TerseSize> docs for more info.

 PerlSetVar StatusTerseSize On

=item StatusTerseSizeMainSummary

With this option On and the B<B::TerseSize> module installed, a
"Memory Usage" will be added to the Apache::Status main menu.  This
option is disabled by default, as it can be rather cpu intensive to
summarize memory usage for the entire server.  It is strongly
suggested that this option only be used with a development server
running in B<-X> mode, as the results will be cached.

 PerlSetVar StatusTerseSizeMainSummary On

=item StatusGraph

When B<StatusDumper> is enabled, another link "OP Tree Graph" will be
present with the dump if this configuration variable is set to On:

 PerlSetVar StatusGraph

This requires the B module (part of the Perl compiler kit) and
B::Graph (version 0.03 or higher) module to be installed along with
the B<dot> program.

Dot is part of the graph visualization toolkit from AT&T:
C<http://www.research.att.com/sw/tools/graphviz/>).

B<WARNING>: Some graphs may produce very large images, some graphs may
produce no image if B::Graph's output is incorrect.  

=item Dot

Location of the dot program for StatusGraph,
if other than /usr/bin or /usr/local/bin

=item GraphDir

Directory where StatusGraph should write it's temporary image files.
Default is $ServerRoot/logs/b_graphs

=back

=head1 PREREQUISITES

The I<Devel::Symdump> module, version B<2.00> or higher.

=head1 SEE ALSO

perl(1), Apache(3), Devel::Symdump(3), Data::Dumper(3), B(3), B::Graph(3)

=head1 AUTHOR

Doug MacEachern


