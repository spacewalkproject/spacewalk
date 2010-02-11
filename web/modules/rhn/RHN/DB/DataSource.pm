#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package RHN::DB::DataSource;

use RHN::DB;
use RHN::Cache::File;
use RHN::Exception qw/throw/;
use File::Spec;
use XML::LibXML;
use Carp;

my $query_data;

# funny system.  if you pass an arrayref in, we assume non-named
# params.  if you pass an array, it must be even length, and then is
# used in execute_h

use constant MAX_BIND_PARAMS => 20;
sub run_complex_query {
  my $self = shift;
  my %params = @_;

  my $original_body = $params{-body};
  my $original_params = $params{-params} || {};

  my @ret;
  my @all_values = @{$original_params->{__sprintf_ids__}};
  delete $original_params->{__sprintf_ids__};

  while (my @values = splice @all_values, 0, MAX_BIND_PARAMS, ()) {
    my %param_map = map { ("p$_", $values[$_]) } 0 .. $#values;
    my $query_body = sprintf $original_body, join(", ", map { ":$_" } keys %param_map);

    my %query_params = %{$original_params};
    @query_params{keys %param_map} = values %param_map;

    push @ret, @{ $self->run_query(-body => $query_body,
				   -params => \%query_params,
				   -transaction => $params{-transaction}) };
  }

  return \@ret;
}

sub run_query {
  my $self = shift;
  my %params = @_;

  my $query_body = $params{-body};
  my $query_params = $params{-params};

  throw "Empty query for mode " . $self->mode()
    unless $query_body;

  my $dbh = $params{-transaction} || RHN::DB->connect($self->dsn);
  my $sth;

  $sth = $dbh->prepare_cached($query_body);

  $sth->execute_h(%{$query_params});

  my @data;

  while (my $row = $sth->fetchrow_hashref) {
    push @data, $row;
  }

  return \@data;
}

sub lookup_mode_data {
  my $self = shift;

  return $self->mode_data()->{$self->mode};
}

sub mode_exists {
  my $self = shift;
  my $mode = shift;

  my $mode_data = $self->mode_data();

  return 1 if exists $mode_data->{$mode};

  return 0;
}

sub mode_data {
  my $self = shift;

  my $xml_dir = $INC{"RHN/DB/DataSource.pm"};
  $xml_dir =~ s/\.pm$/\//;

  my $path = File::Spec->catfile($xml_dir, 'xml');
  my $fc = RHN::Cache::File->new(-name => $self->data_file, -directory => $path, -parser => \&parse);

  my $ret = $fc->parse;

  return $ret;
}

sub parse {
  my $data_to_parse = shift;

  my $mode_data;
  my $parser = XML::LibXML->new();
  my $tree = $parser->parse_string($data_to_parse);
  my $root = $tree->getDocumentElement;

  my @queries = $root->findnodes('query');

  foreach my $query (@queries) {
    my $name = $query->getAttribute('name');
    my $params = $query->getAttribute('params') || '';
    my $multiple = $query->getAttribute('multiple') || 'f';
    my $body = $query->getFirstChild->nodeValue;
    $query_data->{$name} = {params => [ split /,\s*/, $params ],
			    multiple => uc($multiple),
			    body   => $body };
  }

  my @modes = $root->findnodes('mode');

  foreach my $mode (@modes) {
    my $name = $mode->getAttribute('name');
    my @data_query = $mode->findnodes('query');
    my @elab_queries = $mode->findnodes('elaborator');

    my $data_query = $data_query[0];

    my $qname = $data_query->getAttribute('name');

    if ($qname) {
      throw "Attempt to assign non-existent query '$qname' to mode '$name'"
	unless (exists $query_data->{$qname});

      $mode_data->{$name}->{query} = $query_data->{$qname};
    }
    else {
      my $params = $data_query->getAttribute('params');
      my $body = join("",
		      map { $_->nodeValue } grep { $_->nodeType == XML_TEXT_NODE } $data_query->childNodes);

      $mode_data->{$name}->{query} = {params => [ split /,\s*/, $params || "" ],
				      body   => $body };
    }

    $mode_data->{$name}->{elaborators} = [];

    foreach my $elab_query (@elab_queries) {
      my $qname = $elab_query->getAttribute('name');

      if ($qname) {
	throw "Attempt to assign non-existent query '$qname' as elaborator for mode '$name'"
	  unless (exists $query_data->{$qname});

	push @{$mode_data->{$name}->{elaborators}}, $query_data->{$qname};
      }
      else {
	my $params = $elab_query->getAttribute('params') || '';
	my $multiple = $elab_query->getAttribute('multiple') || 'f';
	my $body = $elab_query->getFirstChild->nodeValue;

	push @{$mode_data->{$name}->{elaborators}}, {params => [ split /,\s*/, $params ],
						     multiple => uc($multiple),
						     body   => $body };
      }
    }
  }

  return $mode_data;
}

sub data_file {
  my $self = shift;

  throw "data_file called for base DataSource class."
}

1;
