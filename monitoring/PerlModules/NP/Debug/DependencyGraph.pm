
package NOCpulse::DependencyGraph;

use strict;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;

    $self->{node_counter} = 0;
    $self->{node_name_to_id} = {};
    $self->{node_id_to_name} = {};

    $self->crawl_symbols($main::{'main::'}, {});

    return $self;
}

sub node_to_id
{
    my $self = shift;
    my $name = shift;

    my $id = $self->{node_name_to_id}->{$name};
    if( not defined $id )
    {
	$id = $self->{node_counter}++;
	$self->{node_name_to_id}->{$name} = $id;
	$self->{node_id_to_name}->{$id} = $name;
	$self->{depends_on}->{$id};
    }

    return $id;
}

sub add_dependency
{
    my $self = shift;
    my $from_id = shift;
    my $to_id = shift;
    my $color = shift;

    my $old_color = $self->{depends_on}->{$from_id}->{$to_id};

    if( (not defined $old_color) or ($old_color eq 'black'))
    {
	$self->{depends_on}->{$from_id}->{$to_id} = $color;
    }
}

sub get_dependencies
{
    my $self = shift;
    my $from = shift;

    return \%{$self->{depends_on}->{$from}};
}

sub to_dot
{
    my $self = shift;

    my $dot = '';
    
    $dot .= "digraph code {\n";

    # $dot .= "   size=\"20,20\"\n";
    # $dot .= "   page=\"8,10\"\n";
    # $dot .= "   nodestep=1.5\n";
    
    my $i = 0;
    while( $i < $self->{node_counter} )
    {
	my $label = $self->{node_id_to_name}->{$i};
	# $dot .= "   ".$i." [shape=box,label=\"".$label."\"];\n";
	$dot .= "   ".$i." [fontsize=8,label=\"".$label."\"];\n";
	# $dot .= "   ".$i.";\n";
	$i++;
    }
    
    $i = 0;
    while( $i < $self->{node_counter} )
    {
	my $deps = $self->get_dependencies($i);
	
	my $dep;
	foreach $dep (keys %{$deps})
	{
	    my $color = $deps->{$dep};
	    $dot .= "   ".$i." -> ".$dep." [color=$color];\n";
	}
	$i++;
    }
    
    $dot .= "}\n";

    return $dot;
}

sub crawl_symbols
{
    my $self = shift;
    my $namespace = shift;
    my $seen = shift;
 
    $seen->{$namespace} = 1;
 
    my $symbol;
    if( $namespace =~ /^\*main::(.*)::/ )
    {
        $symbol = $1;
    }
    elsif( $namespace =~ /^\*(.*)::/ )
    {
        $symbol = $1;
    }
    else
    {
        die "parse error: $namespace";
    }
    
    my $k;
 
    foreach $k (sort keys %{$namespace} )
    {
        if( $k =~ /::$/ )
        {
            my $s2 = $symbol."::".$k;
            chop $s2;
            chop $s2;

	    if( $symbol ne 'main' )
	    {
		# 'use' relationship
		my $symbol_id = $self->node_to_id($symbol);
		my $s2_id = $self->node_to_id($s2);
		$self->add_dependency($symbol_id, $s2_id, 'black');
	    }
	    
            if( not $seen->{$namespace->{$k}} )
            {
                crawl_symbols($self, $namespace->{$k}, $seen);
            }
        }
        elsif( $k eq 'ISA' )
        {
            my $i;
            foreach $i (@{$namespace->{$k}})
            {
		# 'isa' relationship
		my $symbol_id = $self->node_to_id($symbol);
		my $i_id = $self->node_to_id($i);
                $self->add_dependency($symbol_id, $i_id, 'red');
            }
        }
    }
 
}

1;

__END__


=pod

=head1 NAME

NOCpulse::DependencyGraph

=head1 SYNOPSIS

  use PackageX;
  use PackageY;
  use PackageZ;
  use NOCpulse::DependencyGraph;

  my $g = NOCpulse::DependencyGraph->new();

  print $g->to_dot();


=head1 DESCRIPTION

A DependencyGraph is a representation of the ISA and 'use' relationship between perl packages.

See 'man dot' for details on the format of the text. 'dot' is open source software available at www.graphviz.org

Red arrows represent ISA relationships.  Black arrows represent 'use' relationships.

