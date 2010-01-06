#
# Copyright (c) 2008--2009 Red Hat, Inc.
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

package Sniglets::ListView::List;

use Sniglets::ListView::Style;
use PXT::Utils;
use PXT::HTML;
use PXT::ACL;
use RHN::DataSource;
use RHN::Exception qw/throw/;

use Data::Dumper;

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use Data::Dumper;

my @valid_fields = qw/listview mode alphabar_column filter_string filter_type style lower upper acl_mixins/;

sub new {
  my $class = shift;
  my %attr = @_;

  my $tree;
  my $root;

  my $self = bless { __listview__ => undef,
		     __mode__ => undef,
		     __datasource__ => undef,
		     __alphabar_column__ => '',
		     __filter_string__ => '',
		     __filter_type__ => 'text',
		     __filter_options__ => { },
		     __style__ => undef,
		     __lower__ => undef,
		     __upper__ => undef,
		     __acl_mixins__ => undef,
		   }, $class;

  $attr{-style} ||= 'standard'; # always set a style

  foreach (@valid_fields) {
    if (exists $attr{"-$_"}) {
      $self->$_($attr{"-$_"} || '');
    }
  }

  return $self;
}

# __Getter/Setters__ #

sub listview {
  my $self = shift;
  my $lv = shift;

  if (defined $lv) {
    $self->{__listview__} = $lv;
  }

  return $self->{__listview__};
}


sub acl_mixins {
  my $self = shift;
  my $mixins = shift;

  if (defined $mixins) {
    $self->{__acl_mixins__} = [split /;\s*/, $mixins];
  }

  return $self->{__acl_mixins__};
}

sub mode {
  my $self = shift;
  my $md = shift;

  if (defined $md) {
    throw "Invalid mode '$md' for list '$self'"
      unless exists $self->mode_data()->{$md};

    my $mode = $self->mode_data()->{$md};
    $self->{__mode__} = $mode;

    $self->datasource($mode->{__datasource__}->clean);
    $self->datasource->mode($md);
  }

  return $self->{__mode__};
}

sub datasource {
  my $self = shift;
  my $ds = shift;

  if (defined $ds) {
    $self->{__datasource__} = $ds;
  }

  return $self->{__datasource__};
}

sub alphabar_column {
  my $self = shift;
  my $ac = shift;

  if (defined $ac) {
    $self->{__alphabar_column__} = $ac;
  }

  return $self->{__alphabar_column__};
}

sub filter_string {
  my $self = shift;
  my $fs = shift;

  if (defined $fs) {
    $self->{__filter_string__} = $fs;
  }

  return $self->{__filter_string__};
}

sub filter_type {
  my $self = shift;
  my $ft = shift;

  if (defined $ft) {
    $self->{__filter_type__} = $ft;
  }

  return $self->{__filter_type__};
}

sub filter_options {
  my $self = shift;
  my $options = shift;

  if (defined $options) {
    $self->{__filter_options__} = $options;
  }

  return $self->{__filter_options__};
}

sub style {
  my $self = shift;
  my $style = shift;

  if (defined $style) {
    #used for systems selected javascript 
    if ($self->listview) {
      $self->{__style__} = new Sniglets::ListView::Style($style, $self->listview->set_label);
    }
    else {
      $self->{__style__} = new Sniglets::ListView::Style($style);
    } 
  }

  return $self->{__style__};
}

sub init_row_counter {
  my $self = shift;

  $self->{__counter__} = 0;
}

# getter only...
sub row_counter {
  my $self = shift;

  return $self->{__counter__};
}

sub incr_row_counter {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  $self->{__counter__}++;
}

# __CLASS METHODS__ #

sub list_of { return "items" }

# ties callback and data function to a particular mode
sub add_mode {
  my $class = shift;
  my $mode_data;

  # okay, let's get rid of requiring the first param be a hash.  if it
  # is a hashref, use the old style, but if it isn't, grab the
  # mode_data hash from the class method in the calling class.
  # sneaky.

  if (ref $_[0] and ref $_[0] eq 'HASH') {
    $mode_data = shift;
  }
  else {
    my ($package) = caller;
    $mode_data = $package->mode_data();
  }

  my %mode_hash = @_;

  warn "pointless action_callback in addmode $mode_hash{-mode}"
    if (exists $mode_hash{-action_callback} and not defined $mode_hash{-action_callback});

  foreach my $req_param (qw/mode datasource/) {
    throw "Missing param '$req_param' adding mode '%mode_hash'."
      unless (exists $mode_hash{"-$req_param"} && defined $mode_hash{"-$req_param"});
  }

  $mode_data->{$mode_hash{-mode}} = {__name__ => $mode_hash{-mode},
				     __provider__ => $mode_hash{-provider} || \&Sniglets::ListView::List::default_provider,
				     __action_callback__ => $mode_hash{-action_callback},
				     __datasource__ => $mode_hash{-datasource},
				    };
}

#given a pxt object and a list of params, return a list of -param, values pairs.
sub lookup_params {
  my $class = shift;
  my $pxt = shift;

  my @params = @_;
  my %ret;

  foreach my $param (@params) {
    my $val;

    if ($param eq 'user_id') {
      $val = $pxt->user->id;
    }
    elsif ($param eq 'org_id') {
      $val = $pxt->user->org_id;
    }
    elsif ($param eq 'set_label' && !($pxt->dirty_param('set_label'))) {
      $val = 'system_list';
    }
    elsif ($param eq 'search_string') {
      $val = '%' . $pxt->dirty_param('search_string') . '%';
    }
    elsif ($param eq 'formvar_uid') { # 'uid' is a reserved word to oracle - can't be a bind param
      $val = $pxt->param('uid');
    }
    elsif ($param eq 'name_id' and $pxt->dirty_param('id_combo')) {
      $val = (split /\|/, $pxt->dirty_param('id_combo'))[0];
    }
    elsif ($param eq 'evr_id' and $pxt->dirty_param('id_combo')) {
      $val = (split /\|/, $pxt->dirty_param('id_combo'))[1];
    }
    else {
      $val = $pxt->passthrough_param($param);
    }

    next unless defined $val;

    $ret{"-$param"} = $val;
  }

  return %ret;
}

# __OBJECT METHODS__ #

# Should be called every time a button is pushed
sub callback {
  my $self = shift;
  my $pxt = shift;

  PXT::Debug->log(4, "entering " . (ref $self) . " list callback...");

  my $mode = $self->mode;

# determine if an action button was pressed
  my ($action_label) = grep { /^list_action_label_/ } $pxt->param();

  my %action;
  if ($action_label) {
    $action_label =~ s/list_action_label_//;
    $action{label} = $action_label;
    $action{url} = $pxt->dirty_param("list_action_url_${action_label}");
  }

  my %vars;

  foreach my $formvar ($pxt->dirty_param('formvars')) {
    next unless $pxt->passthrough_param($formvar);
    $vars{$formvar} = $pxt->passthrough_param($formvar);
  }


  if (my $set_label = $pxt->dirty_param('list_set_label')) {
    my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

    if ($pxt->dirty_param('select_all')) {
      my %results = $mode->{__provider__}->($self, $pxt);
      unless (exists $results{all_ids} and exists $results{data}) {
	throw "Provider for mode did not provide all_ids and data: " . Data::Dumper->Dump([$mode]);
      }

      $set->add(@{$results{all_ids}});
      $set->commit;
      $self->clean_set($set, $pxt->user, \%vars);
    }
    elsif ($pxt->dirty_param('unselect_all')) {
      $set->empty;
      $set->commit;
    }
    else {
      my @set_contents = map { ref $_ ? $_->[0] . "|" . $_->[1] : $_} $set->contents;

      my %on_page = map { ($_ => 1) } $pxt->dirty_param("items_on_page");
      my %selected = map { ($_ => 1) } $pxt->dirty_param("items_selected");

      # intersect set with what is on the page for what was selected before
      my %previously_selected;
      foreach my $old_selection (@set_contents) {
	$previously_selected{$old_selection} = 1 if (exists $on_page{$old_selection});
      }

      my @removed;
      my @added;
      foreach my $id (keys %on_page) {
	push @removed, $id if ($previously_selected{$id} && !$selected{$id});
	push @added, $id if (!$previously_selected{$id} && $selected{$id});
      }

      $set->remove(@removed) if (@removed);
      $set->add(@added) if (@added);

      if (@removed or @added) {
	$set->commit;
	$self->clean_set($set, $pxt->user, \%vars);

	$self->set_new_members_cb(@added) if (@added);
	$self->set_removed_members_cb(@removed) if (@removed);
      }
    }

    if ($action{label}) {
      if (! $set->contents) { # set is empty
	%action = $self->empty_set_action_cb($pxt, %action);
      }
    }
  } # if (my $set_label = ...)

  my $action_success = 1;
  if (my $cb = $mode->{__action_callback__}) {
    $action_success = 0;
    PXT::Debug->log(4, "callback:  $cb");
    $action_success = $cb->($self, $pxt, %action);
  }

  if ($pxt->dirty_param('Prev') || $pxt->dirty_param('Prev.x')) {
    $vars{lower} = $pxt->dirty_param('prev_lower');
    $vars{upper} = $pxt->dirty_param('prev_upper');
  }
  elsif ($pxt->dirty_param('Next') || $pxt->dirty_param('Next.x')) {
    $vars{lower} = $pxt->dirty_param('next_lower');
    $vars{upper} = $pxt->dirty_param('next_upper');
  }
  elsif ($pxt->dirty_param('First') || $pxt->dirty_param('First.x')) {
    $vars{lower} = $pxt->dirty_param('first_lower');
    $vars{upper} = $pxt->dirty_param('first_upper');
  }
  elsif ($pxt->dirty_param('Last') || $pxt->dirty_param('Last.x')) {
    $vars{lower} = $pxt->dirty_param('last_lower');
    $vars{upper} = $pxt->dirty_param('last_upper');
  }
  else {
    $vars{lower} = $self->lower;
    $vars{upper} = $self->upper;
  }

  if (defined $pxt->dirty_param('filter_value')) {
    $vars{filter_string} = $pxt->dirty_param('filter_value');

    if (defined $pxt->dirty_param('prev_filter_value') and
	$pxt->dirty_param('prev_filter_value') ne $pxt->dirty_param('filter_value')) {
      $vars{lower} = 1;
      $vars{upper} = $pxt->user->preferred_page_size;
    }
  }



  if (defined $pxt->dirty_param('message')) {
     $vars{'message'} = $pxt->passthrough_param('message');
     my @mess_params = ('messagep1', 'messagep2', 'messagep3');
     foreach my $mess_param (@mess_params){
        if (defined $pxt->dirty_param($mess_param)) {
            $vars{$mess_param} = $pxt->passthrough_param($mess_param);
	}
     }
  }

  my $base = $pxt->uri;
  if ($action_success) {
    if ($action{label}) { # an action button was pressed
      delete $vars{lower};
      delete $vars{upper};
      delete $vars{filter_string};
      delete $vars{alphabar_column};
    }

    if ($action{url}) {
      $base = $action{url};
    }
  }

  my $additional_vars = join("\&", map { "$_=" . PXT::Utils->escapeURI($vars{$_}) } keys %vars);
  if ($additional_vars) {
    $additional_vars = $base =~ /\?/ ? '&' . $additional_vars : '?' . $additional_vars;
  }

  my $redir = $base . $additional_vars;
  $pxt->redirect($redir);
}

sub formvars {
  my $self = shift;
  my $pxt = shift;

  my %ret;

  unless (defined $self->listview()) {
    throw "no listview";
  }

  foreach my $formvar (@{$self->listview->formvars}) {
    if ($formvar->type eq 'literal') {
      $ret{$formvar->name} = $formvar->value;
    }
    elsif ($formvar->type eq 'propagate') {
      $ret{$formvar->name} = $pxt->passthrough_param($formvar->name)
	if defined $pxt->passthrough_param($formvar->name);
    }
    else {
      die "unknown formvar type: " . $formvar->type;
    }
  }

  my @extra_formvars = qw/filter_string alphabar_column/;

  foreach my $formvar (@extra_formvars) {
    $ret{$formvar} = $pxt->passthrough_param($formvar)
      if defined $pxt->passthrough_param($formvar);
  }

  return \%ret;
}

sub render_formvars {
  my $self = shift;
  my $pxt = shift;

  my $vars = $self->formvars($pxt);
  my $ret = '';

  $vars->{alphabar_column} = $self->alphabar_column || '';

  foreach my $var (keys %{$vars}) {
    $ret .= PXT::HTML->hidden(-name => $var, -value => PXT::Utils->escapeHTML($vars->{$var} || ''));
    $ret .= PXT::HTML->hidden(-name => "formvars", -value => $var);
  }

  return $ret;
}

sub render_alphabar {
  my $self = shift;
  my $alphabar = shift;
  my $pagesize = shift;
  my $url = shift;
  my $vars = shift;

  my @ret;
  my @attr;

  foreach my $alpha ('A' .. 'Z', '0' .. '9') {

    if (exists $alphabar->{$alpha}) {
      my $base = $alphabar->{$alpha};
      my ($lower, $upper) = ($base, $base + $pagesize - 1);

      $vars->{lower} = $lower;
      $vars->{upper} = $upper;

      my $varstring = join('&amp;', map { "$_=" . PXT::Utils->escapeURI($vars->{$_}) } keys %{$vars});

      push @ret, qq{<A HREF="$url?$varstring" class="list-alphabar-enabled">$alpha</A>};
    }
    else {
      push @ret, qq {<span class="list-alphabar-disabled">$alpha</span>};
    }
  }

  my $bar = qq(<div align="center"><strong>\n) . join("", @ret) . qq(\n</strong></div>\n<br />\n);

  my $html = $self->style->alphabar;
  $html =~ s/\{alphabar\}/$bar/;

  return $html;
}

sub render_filterbox {
  my $self = shift;
  my $pxt = shift;

  my $ret;

  my ($filter_by) = grep { $_->sort_by } @{$self->listview->columns};

  throw "No 'sort_by' column for mode '" . $self->mode->{__name__} . "'\n" unless defined $filter_by;

  $ret .= q{<div class="filter-input">};
  $ret .= sprintf('Filter by %s: ', $filter_by->name);
  if ($self->filter_type eq 'text') {
    $ret .= PXT::HTML->text(-name => 'filter_value', -value => PXT::Utils->escapeHTML($self->filter_string || ''), -size => 12);
    $ret .= PXT::HTML->hidden(-name => 'prev_filter_value', -value => PXT::Utils->escapeHTML($self->filter_string || ''));
  }
  elsif ($self->filter_type eq 'select') {
    $ret .= PXT::HTML->select(-name => 'filter_value',
			      -size => 1,
			      -options => [ [ '--all--', '', not $self->filter_string ],
					    map { [ $_, $_, $_ eq ($self->filter_string || '') ] }
					      keys %{$self->filter_options} ] );
    $ret .= PXT::HTML->hidden(-name => 'prev_filter_value', -value => PXT::Utils->escapeHTML($self->filter_string || ''));
  }
  else {
    throw "Unknown filter type: '" . $self->filter_type . "'";
  }

  $ret .= " ";
  $ret .= PXT::HTML->submit_image(-src => '/img/button-go.gif', -alt => "Filter", -name => "filter_list");
  $ret .= q{</div>};

  return $ret;
}

sub render_select_buttons {
  my $self = shift;
  my $pxt = shift;
  my $block = shift;
  my $set_acl_failed = shift;


  my $button_str = '';

  unless ($set_acl_failed) {
    # only render the 'Update' button if a) there are selectable rows and b) there aren't any BRB's...
    if ($self->{__any_selectable_rows__}) {
      $button_str .= qq(<input type="submit" name="add_to_selection" value="Update List"/> );
    }

    if ($self->allow_selections($pxt) and my $set = $self->{__set__}) {
        my $num_selected = $set->contents();

        if ($self->{__any_selectable_rows__}) {
          $button_str .= qq(<input type="submit" name="select_all" value="Select All"/> );
        }

        if ($num_selected) {
          $button_str .= qq(<input type="submit" name="unselect_all" value="Unselect All"/> );
        }

    }
    if ($self->{__any_selectable_rows__}) {
      $button_str = qq(<span class="list-selection-buttons">) . $button_str . qq(</span>) ;
    }
    
  }

  $block = PXT::Utils->perform_substitutions($block, {control_area => $button_str});
  return $block;
}

sub render_set_info {
  my $self = shift;
  my $pxt = shift;
  my $block = shift;
  my $pos = shift;

  my $subst = { };

  if ($self->allow_selections($pxt) and $self->{__set__}) {
    my $num_contents = scalar $self->{__set__}->contents;
    $subst->{set_string} = sprintf('<span id="pagination_selcount_%s">(%s selected)</span>', $pos, $num_contents);
  }
  else {
    $subst->{set_string} = '';
  }

  $block = PXT::Utils->perform_substitutions($block, $subst);
  return $block;
}

sub render_page_info {
  my $self = shift;
  my $pxt = shift;
  my $block = shift;

  my $subst = { };
  @{$subst}{qw/current_lower current_upper total/} = ($self->lower, $self->upper, scalar @{$self->all_ids});

  $block = PXT::Utils->perform_substitutions($block, $subst);

  return $block;
}

sub render_pagination_formvars {
  my $self = shift;
  my $pxt = shift;
  my $ret = shift;

  my $hidden_vars = '';

  $hidden_vars .= PXT::HTML->hidden(-name => 'lower', -value => "{current_lower}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'upper', -value => "{current_upper}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'first_lower', -value => "{first_lower}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'first_upper', -value => "{first_upper}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'last_lower', -value => "{last_lower}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'last_upper', -value => "{last_upper}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'next_lower', -value => "{next_lower}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'next_upper', -value => "{next_upper}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'prev_lower', -value => "{prev_lower}");
  $hidden_vars .= PXT::HTML->hidden(-name => 'prev_upper', -value => "{prev_upper}");

  my $block = PXT::Utils->paginate_variables($hidden_vars, $self->upper, $self->lower, scalar @{$self->all_ids}, $pxt->user->preferred_page_size);

  $ret =~ s/\{hidden_vars\}/$block/;
  return $ret;
}

sub render_pagination_buttons {
  my $self = shift;
  my $pxt = shift;
  my $block = shift;

  my ($upper, $lower, $total) = ($self->upper, $self->lower, scalar @{$self->all_ids});
  $upper = $total if $upper > $total;

  my $forward_status = $upper < $total;
  my $back_status = ($lower != 1);

  my $forward_status_str = $forward_status ? "" : "-unfocused";
  my $back_status_str = $back_status ? "" : "-unfocused";

  my $forward_buttons_str = "&#160;";
  my $back_buttons_str = "&#160;";

  # show buttons
  if ($lower != '1' || ($upper != $total)) {
    $back_buttons_str = $self->render_pagination_button("First", "/img/list-allbackward$back_status_str.gif", " |&lt; ", $back_status);
    $back_buttons_str .= $self->render_pagination_button("Prev", "/img/list-backward$back_status_str.gif", " &lt; ", $back_status);
    $forward_buttons_str = $self->render_pagination_button("Next", "/img/list-forward$forward_status_str.gif", " &gt; ", $forward_status);
    $forward_buttons_str .= $self->render_pagination_button("Last", "/img/list-allforward$forward_status_str.gif", " &gt;| ", $forward_status);
  }

  my %subst;

  $subst{back_buttons_str} = $back_buttons_str;
  $subst{forward_buttons_str} = $forward_buttons_str;

  $block = PXT::Utils->perform_substitutions($block, \%subst);

  return $block;
}

sub render_pagination_button {
  my $self = shift;
  my $name = shift;
  my $img_file = shift;
  my $text = shift;
  my $is_active = shift;

  my $ret = '';

  if ($is_active) {
    $ret = <<EOH
<input type="image" src="$img_file" border="0" name="$name" value="$text" class="list-nextprev-active" />
EOH
  }
  else {
    $ret = <<EOH
<img src="$img_file" border="0" alt="$text" title="$text" class="list-nextprev-inactive" />
EOH
  }

  return $ret;
}

sub render_rows_header {
  my $self = shift;
  my $skip_columns = shift;

  my $col_str = '';

  if ($self->listview->set_label and not defined $skip_columns->{Select}) {
    $col_str .= $self->style->select_column_header;
    $col_str =~ s/\{list_of\}/$self->list_of/ge;
  }

  foreach my $col (@{$self->listview->columns}) {
    my $col_name = $col->name;
    my $column = $self->style->header_column;
    next if exists $skip_columns->{$col->name};

    my @attribs;

    foreach my $attrib (qw/width align nowrap/) {
      if ($col->$attrib()) {
	push @attribs, $attrib . '="' . $col->$attrib() . '"';
      }
    }

    if (@attribs) {
      unshift @attribs, '';
    }

    $column =~ s/\{attr_string\}/join " ", @attribs/e;
    $column =~ s/\{column_name\}/$col_name/;

    $col_str .= $column;

  }

  chomp($col_str);

  my $header = $self->style->header;

  $header =~ s/\{header_row\}/$col_str/g;

  return $header;
}

sub render_rows_footer {
  my $self = shift;

  my $numcols = scalar @{$self->listview->columns};

  if ($self->listview->set_label) {
    $numcols++;
  }

  my $footer = $self->style->footer;
  $footer =~ s/\{numcols\}/$numcols/g;

  return $footer;
}

sub render_action_items {
  my $self = shift;
  my $pxt = shift;

  my $ret = '';

  my @action_items = @{$self->listview->actions};

  my $count = 0;
  my $any_rendered;

  my $acl_parser;

  foreach my $action (@action_items) {
    $count++;

    $acl_parser = new PXT::ACL(mixins => $self->acl_mixins);

    my $url = $action->url || '';
    my $label = $action->label || $count;
    my $class = $action->class || '';
    my $acl = $action->acl;

    if ($acl) {
      PXT::Debug->log(7, "evaluating action acl:  $acl");
      next unless $acl_parser->eval_acl($pxt, $acl);
      PXT::Debug->log(7, "action acl passed!");
    }

    $any_rendered = 1;

    $ret .= PXT::HTML->submit(-name => "list_action_label_$label",
			      -value => $action->name,
			      ($class ? (-class => $class) : () )
			     ) . "\n";
    $ret .= PXT::HTML->hidden(-name => "list_action_url_$label",
			      -value => $url) . "\n";
  }

  if ($any_rendered) {

    $ret = "<div align=\"right\">\n<hr />\n$ret\n</div>\n";
  }

  return $ret;
}

sub render_url {
  my $self = shift;
  my $pxt = shift;
  my $url = shift;
  my $row = shift;
  my $url_column = shift;

  return '' unless (defined $row->{$url_column});

  if ($row->{$url_column} eq '0') {
    return '0';
  }

  # replace the various stubs in the url...
  $url =~ s{\{column:(.*?)\}}{PXT::Utils->escapeURI($row->{uc "$1"})}ge;

  return sprintf("<a href=\"%s\">%s</a>", $url, $row->{$url_column});
}

sub render_checkbox {
  my $self = shift;
  my %params = validate(@_, { row => 1, checked => 1, blank => 0, pxt => 0 });

  my $checkbox_template = $self->style->checkbox();
  my $checkbox;

  my $set_label = $self->listview->set_label;
  if ($params{blank}) {
    $checkbox = '&#160;';
  }
  else {
    $checkbox = PXT::HTML->checkbox(-name => 'items_selected',
				    -value => $params{row}->{ID},
				    -checked => $params{checked},
				    -onClick => "checkbox_clicked(this, '$set_label')");

    $checkbox .= PXT::HTML->hidden(-name => 'items_on_page',
				   -value => $params{row}->{ID});

  }

  $checkbox_template =~ s/\{checkbox\}/$checkbox/;

  return $checkbox_template;
}

sub render_empty_list_message {
  my $self = shift;

  my $empty_list_message = $self->listview->empty_list_message || $self->default_empty_message();

  my $block = $self->style->empty_list_wrapper;

  $block = PXT::Utils->perform_substitutions($block, {empty_list_message => $empty_list_message});
  return $block;
}


sub render {
  my $self = shift;
  my $pxt = shift;

  my @columns = @{$self->listview->columns};
  my %col_hash;

  my $acl_parser = new PXT::ACL(mixins => $self->acl_mixins);

  my %acl_failures;
  foreach my $col (@columns) {
    $col_hash{$col->name} = { label => $col->label,
			      width => $col->width,
			      align => $col->align,
			      nowrap => $col->nowrap,
			    };

    if ($col->acl) {
      $acl_failures{$col->name} = 1
	unless $acl_parser->eval_acl($pxt, $col->acl);
    }
  }

  my $mode = $self->mode;
  my $provider = $mode->{__provider__};

  throw "No provider registered for mode: ", $mode->{__name__} unless $provider;

  my %results = $provider->($self, $pxt);
  unless (exists $results{all_ids} and exists $results{data}) {
    throw "Provider for mode did not provide all_ids and data: " . Data::Dumper->Dump([$mode]);
  }

  if ($results{all_ids} and $self->upper > scalar @{$results{all_ids}}) {
    $self->upper(scalar @{$results{all_ids}});
  }

  my $set_label = $self->listview->set_label;
  my $set_acl_string = $self->listview->set_acl;

  if ($set_acl_string) {
    PXT::Debug->log(7, "set_acl_string:  $set_acl_string");

    my $set_acl = new PXT::ACL(mixins => $self->acl_mixins);
    my $set_acl_pass = $set_acl->eval_acl($pxt, $set_acl_string);
    $acl_failures{Select} = 1 unless $set_acl_pass;
    PXT::Debug->log(7, "set_acl_passed:  " . (defined $acl_failures{Select} ? 'no' : 'yes'));
  }
  else {
    PXT::Debug->log(7, "no set_acl_string!");
  }

  my $ret = "<!-- Begin List -->\n";

  if ($set_label) {
    $col_hash{'Select'} = { label => 'select', width => '5%' };
    $self->{__set__} = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);
  }

  unless (scalar @{$results{data}}) {

    if ($self->filter_string) {
      $ret .= PXT::HTML->form_start(-name => 'rhn_list', -method => "POST", -action => $pxt->uri) . "\n";
      $ret .= $self->render_filterbox($pxt) . '<br />';
      $ret .= $self->render_empty_list_message();
      $ret .= $self->render_formvars($pxt);
      $ret .= PXT::HTML->hidden(-name => "pxt:trap", -value => $self->trap());
      $ret .= PXT::HTML->hidden(-name => "list_mode", -value => $mode->{__name__});

      if ($self->{__set__}) {
	$ret .= PXT::HTML->hidden(-name => "list_set_label", -value => $self->{__set__}->label);
      }

      $ret .= PXT::HTML->form_end;
      return $ret;
    }
    else {
      return $self->render_empty_list_message();
    }
  }

  # ok, we had results, drop the legend renderer a note...
  my $legend_type = 'legend:' . $self->list_of;
  $pxt->pnotes($legend_type => 1);

  my $filter = '&#160;';



  my $alphabar;
  if (exists $results{alphabar} && defined $results{alphabar}) {
    $alphabar = "&#160;";

    if (scalar @{$results{all_ids}} > $pxt->user->preferred_page_size) {

      $alphabar = $self->render_alphabar($results{alphabar},
					 $pxt->user->preferred_page_size,
					 $pxt->uri,
					 $self->formvars($pxt));

    }

    $filter = $self->render_filterbox($pxt);
  }

  $ret .= $alphabar if $alphabar;

  $ret .= PXT::HTML->form_start(-name => 'rhn_list', -method => "POST", -action => $pxt->uri) . "\n";

  my $pagination = $self->style->pagination;

  $pagination = $self->render_pagination_buttons($pxt, $pagination);
  $pagination = $self->render_pagination_formvars($pxt, $pagination);
  $pagination = $self->render_set_info($pxt, $pagination, 'top');
  $pagination = $self->render_page_info($pxt, $pagination);
  $pagination =~ s/\{control_area\}/$filter/;

  $ret .= $pagination;

  $ret .= $self->render_rows_header(\%acl_failures);

  $self->init_row_counter();

  my $row_template = $self->style->row();

  my $row_class_odd = $self->style->row_class_odd();
  my $row_class_even = $self->style->row_class_even();

  my $checkboxes_on_page = 0;
  my $checkboxes_checked = 0;
  my $num_rendered_columns = scalar @columns;

  $num_rendered_columns++ if defined $self->{__set__};

  foreach my $row (@{$results{data}}) {
    PXT::Debug->log(7, "row:  " . Data::Dumper->Dump([($row)]));

    $row = $self->row_callback($row, $pxt);
    my $html = $row_template;

    $self->incr_row_counter($row, $pxt);
    
    # If we're displaying a list that has disabled set in it (like a user list),
    # display the correct css
    if (exists $row->{DISABLED} and $row->{DISABLED} eq 'Disabled') {
      $html =~ s/\{row-class\}/$self->row_counter() % 2 ? $row_class_odd . "-disabled" : $row_class_even . "-disabled"/eg
    }
    else {
      $html =~ s/\{row-class\}/$self->row_counter() % 2 ? $row_class_odd : $row_class_even/eg; 
    }

    my $checkbox_html = '';

    my $current_col_index = 0;

    if ($set_label and not defined $acl_failures{Select}) {
      my $checked = $self->{__set__}->contains($row->{ID});

      if ($self->is_row_selectable($pxt, $row)) {
	$self->{__any_selectable_rows__} = 1;

	$checkbox_html = $self->render_checkbox(-row => $row, -checked => $checked, -pxt => $pxt);

	if ($checked) {
	  $checkboxes_checked++;
	}

	$checkboxes_on_page++;
      }
      else {
	$checkbox_html = $self->render_checkbox(-row => $row, -checked => $checked, -blank => 1, -pxt => $pxt);
      }

      $current_col_index++;
    }

    $html =~ s/\{checkbox\}/$checkbox_html/g;

    my $columns;
    my $col_template = $self->style->column();

    foreach my $col (@columns) {

      my $col_html = $col_template;
      my $col_name = $col->name;

      next if exists $acl_failures{$col->name};

      if ($col_name ne 'Select') {
	my $label = $col->label;

	# if the row doesn't have the value, but it is the special
	# multiple row per id result type, test the first of the multiple results
	# for the value.  if it exists, string 'em together.
	if (not exists $row->{uc $label} and defined $row->{__data__}) {

	  PXT::Debug->log(7, "trying to find data to string together for $label...");

	  if ($row->{__data__}->[0]->{uc $label}) {

	    $row->{uc $label} = '';
	    foreach my $value (map {$_->{uc $label}} @{$row->{__data__}}) {
	      my $escaped_value = PXT::Utils->escapeHTML($value);
	      $row->{uc $label} .= "$escaped_value<br />\n";
	    }

	    PXT::Debug->log(7, "figured out $label:  " . $row->{uc $label});
	  }
	  else {
	    die "failed to find data named '$label', elaborator query might have failed to return any results";
	  }
	}

	if (not defined $col->content and not exists $row->{uc $label}) {
	  throw sprintf("Provider for '%s' failed to provide column '%s'\nRow data:  %s",
			$mode->{__name__}, uc($label), Data::Dumper->Dump([$row]) );
	}
	elsif (defined $col->content and exists $row->{uc $label}) {
	  throw sprintf("Provider for '%s' provided a column that has static content '%s'\nRow data:  %s",
			$mode->{__name__}, uc($label), Data::Dumper->Dump([$row]) );
	}

	if (defined $col->content) {
	  $row->{uc $label} = $col->content;
	}

	$row->{uc $label} = sprintf "%s%s%s",
	  $col->pre_content || '',
	    (defined $row->{uc $label} ? $row->{uc $label} : ''),
	      $col->post_content || '';
	my $col_data = defined $row->{uc $label} ? $row->{uc $label} : '';

	if ($col->is_date()) {
	  $col_data = $pxt->user->convert_time($col_data);
	}


	if ($col->htmlify) { #HTML already escaped in 'escape_row'
	  $col_data = PXT::HTML->htmlify_text_no_escape($col_data);
	}

	# figure out if we need to hyperlink the column's data...
	my $url = $col->url;

	if ($url) {
	  $col_data = $self->render_url($pxt, $url, $row, uc($label));
	}

	my ($width_str, $align_str, $nowrap_str, $class_str) = ('', '', '', '');

	# sometimes there is no header row to be in charge of widths
 	if (my $width = $col->width) {
 	  $width_str = sprintf(' width="%s"', $width);
 	}
	my $col_align = $col->align;

	if ($col_align) {
	  $align_str = sprintf(' align="%s"', $col_align);
	}

	if ($col->nowrap) {
	  $nowrap_str = sprintf(' nowrap="%s"', $col->nowrap);
	}

	# custom td classes for first and last in row, sorta useful
	if ($current_col_index == 0) {
	  $class_str = ' class="first-column"';
	}
	elsif ($current_col_index == ($num_rendered_columns - 1)) {
	  $class_str = ' class="last-column"';
	}

	$col_html =~ s/\{align_str\}/$align_str/g;
	$col_html =~ s/\{width_str\}/$width_str/g;
	$col_html =~ s/\{class_str\}/$class_str/g;
	$col_html =~ s/\{nowrap_str\}/$nowrap_str/g;
	$col_html =~ s/\{col_data\}/$col_data/g;
	$columns .= $col_html;

	$current_col_index++;
      }
    }

    $html =~ s/\{columns\}/$columns/g;

    $ret .= $html;
  }

  $ret =~ s/\{checkall_disabled\}/$checkboxes_on_page ? '' : ' disabled="1"'/e;
  $ret =~ s/\{checkall_checked\}/($checkboxes_on_page == $checkboxes_checked) ? ' checked="1"' : ''/e;

  $ret .= $self->render_rows_footer();

  $pagination = $self->style->pagination;

  $pagination = $self->render_pagination_buttons($pxt, $pagination);
  $pagination = $self->render_set_info($pxt, $pagination, 'bottom');
  $pagination = $self->render_page_info($pxt, $pagination);

  $pagination = $self->render_select_buttons($pxt, $pagination,  $acl_failures{'Select'});

  $pagination =~ s/\{hidden_vars\}//;

  $ret .= $pagination;

  $ret .= PXT::HTML->hidden(-name => "pxt:trap", -value => $self->trap());
  $ret .= PXT::HTML->hidden(-name => "list_mode", -value => $mode->{__name__});

  if ($self->{__set__}) {
    $ret .= PXT::HTML->hidden(-name => "list_set_label", -value => $self->{__set__}->label);
  }

  $ret .= $self->render_action_items($pxt);

  $ret .= $self->render_formvars($pxt);
  $ret .= PXT::HTML->form_end();

  $ret .= "\n<!-- End List -->";

  return $ret;
}

sub default_provider {
  my $self = shift;
  my $pxt = shift;
  my %extra_params = @_;

  my $ds = $self->datasource;

  my %params = $self->lookup_params($pxt, $ds->required_params);

  my $data = $ds->execute_query(%params, %extra_params);

  $data = $self->filter_data($data);
  my $alphabar = $self->init_alphabar($data);

  my $all_ids = [ map { $_->{ID} } @{$data} ];
  $self->all_ids($all_ids);

  $data = $ds->slice_data($data, $self->lower, $self->upper);
  $data = $ds->elaborate($data, %params, %extra_params);

  foreach my $row (@$data) {
    escape_row($row);
  }

  return (data => $data,
	  all_ids => $all_ids,
	  alphabar => $alphabar);
}

sub escape_row {
  my $row = shift;

  foreach my $key (keys %$row) {
    if (ref $row->{$key} eq 'ARRAY') {
      foreach my $subrow (@{$row->{$key}}) {
	if (ref $subrow eq 'HASH') {
	  escape_row($subrow);
	}
	else {
	  $subrow = PXT::Utils->escapeHTML($subrow);
	}
      }
    }
    elsif (defined $row->{$key}) {
      $row->{$key} = PXT::Utils->escapeHTML($row->{$key});
    }
  }
}

sub filter_data {
  my $self = shift;
  my $data = shift;

  my $filtered_data = [];
  my $filter_options = { };
  my $filter_type = $self->filter_type;

  my $column = $self->alphabar_column || '';
  my $filter_value = $self->filter_string || '';

  if ($filter_type eq 'select') {
    $filter_options->{$_->{$column}}++
      foreach (@{$data});

    $self->filter_options($filter_options);
  }

  return $data unless $filter_value;

  foreach my $row (@$data) {
    push @$filtered_data, $row
      if index(uc $row->{$column}, uc $filter_value) >= 0;
  }

  return $filtered_data;
}

sub init_alphabar {
  my $self = shift;
  my $data = shift;

  my $column = uc($self->alphabar_column);

  return unless $column;

  my $lastalpha = '';
  my $count = 1;

  my $alphabar;

  foreach my $row (@{$data}) {
    throw "Column '$column' does not exist in row '" . Data::Dumper->Dump([($row)]) . "'\n"
      unless exists $row->{$column};

    my $alpha = '';
    if ($row->{$column}) {
      $alpha = uc(substr $row->{$column}, 0, 1);
    }

    if ($alpha ne $lastalpha) {
      $alphabar->{$alpha} = $count;
      $lastalpha = $alpha;
    }
    $count++;
  }

  return $alphabar;
}

sub lower {
  my $self = shift;
  my $lower = shift;

  if (defined $lower) {
    $self->{__lower__} = $lower;
  }

  return $self->{__lower__};
}

sub upper {
  my $self = shift;
  my $upper = shift;

  if (defined $upper) {
    $self->{__upper__} = $upper;
  }

  return $self->{__upper__};
}

sub all_ids {
  my $self = shift;
  my $all_ids = shift;

  if (defined $all_ids) {
    $self->{__all_ids__} = $all_ids;
  }

  return $self->{__all_ids__};
}

# __Overridable Methods__ #

# A child class overrides this function to register modes
sub register_modes {
  my $self = shift;

  my $class = (ref $self ? ref $self : $self);
  throw "Class $class did not provide a register_modes!";
}

# The name of the list callback function - matches Sniglets/Lists.pm
sub trap {
  my $self = shift;

  my $class = (ref $self ? ref $self : $self);
  throw "Class $class did not provide a trap!";

  return;
}

# Override this to provide a default empty list message
sub default_empty_message {
  my $self = shift;

  my $things = $self->list_of;

  return "No $things.";
}

# called after the set tied to the list gets things added to it due to action.
# useful for, say, permission checking, etc.
sub set_new_members_cb {
  my $self = shift;
  my @added = @_;

  PXT::Debug->log(5, "added:  " . join(", ", @added));
}

# called after the set tied to the list gets things removed from it due to action.
# not quite certain if this will be useful yet...
sub set_removed_members_cb {
  my $self = shift;
  my @removed = @_;

  PXT::Debug->log(5, "removed: " . join(", ", @removed));
}

# If an action button was pressed, and the set is empty, generally
# clear the action, and push an error onto the stack.
sub empty_set_action_cb {
  my $self = shift;
  my $pxt = shift;
  my %action = @_;

  my $things = $self->list_of;

  $pxt->push_message(site_info => "No $things selected.");

  return (); # clear the action
}

# override this if you want to, say, make a new row via perl based upon the data provided
sub row_callback {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  # nada...
  return $row;
}

# can override this... will be useful for removing the select box for unentitled systems, etc.
sub is_row_selectable {
  my $self = shift;
  my $pxt = shift;
  my $row = shift;

  return 1;
}

sub allow_selections {
  my $self = shift;
  my $pxt = shift;

  return 1;
}

#override to clean a set after all_ids are inserted
sub clean_set {
  my $self = shift;
  my $set = shift;
  my $user = shift;
  my $formvars = shift;

  return;
}

1;
