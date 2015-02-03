#
# Copyright (c) 2008 Red Hat, Inc.
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

package Sniglets::Forms::Style;
use strict;

sub new {
  my $class = shift;
  my $style_name = shift;

  if ($style_name) {
    return bless { style_name => $style_name }, "${class}::$style_name";
  }
  else {
    return bless { style_name => "standard" }, "${class}::standard";
  }
}

package Sniglets::Forms::Style::standard;

sub form_header {
  my $self = shift;
  my $form_header = shift;

  my $ret = <<EOQ;
$form_header
EOQ

  return $ret;
}

sub rows_header {
  my $self = shift;
  my $name = shift;

  my $ret = <<EOQ;
  <table class="details" align="center">
EOQ

  return $ret;
}

sub row {
  my $self = shift;
  my $label = shift;
  my $name = shift;
  my @elements = @_;

  my $element = join "<br/>\n", @elements;

  my $ret = <<EOQ;
    <tr>
      <th>${name}:</th>
      <td>$element</td>
    </tr>
EOQ

  return $ret;
}

sub required_row {
  my $self = shift;
  my $label = shift;
  my $name = shift;
  my @elements = @_;

  my $element = join "<br/>\n", @elements;

  my $ret = <<EOQ;
    <tr>
      <th>${name}<span class="required-form-field">*</span>:</th>
      <td>$element</td>
    </tr>
EOQ

  return $ret;
}

sub rows_footer {
  my $self = shift;

  my $ret = <<EOQ;
  </table>
EOQ

  return $ret;
}

sub hidden_row {
  my $self = shift;
  my @elements = @_;

  my $elements = join "\n", @elements;

  my $ret = <<EOQ;
$elements
EOQ

  return $ret
}

sub submit_row {
  my $self = shift;
  my @elements = @_;

  my $elements = join "\n", @elements;

  my $ret = <<EOQ;
  <div align="right">
    <hr />
    $elements
  </div>
EOQ

  return $ret;
}

sub form_footer {
  my $self = shift;

  my $ret = <<EOQ;
</form>
EOQ

  return $ret;
}

package Sniglets::Forms::Style::survey;

use base qw/Sniglets::Forms::Style::standard/;

sub row {
  my $self = shift;
  my $label = shift;
  my $name = shift;
  my @elements = @_;

  my $element = join "<br/>\n", @elements;

  my $ret = <<EOQ;
    <tr>
      <th width="40%">${name}:</th>
      <td width="60%">$element</td>
    </tr>
EOQ

  return $ret;
}

sub required_row {
  my $self = shift;
  my $label = shift;
  my $name = shift;
  my @elements = @_;

  my $element = join "<br/>\n", @elements;

  my $ret = <<EOQ;
    <tr>
      <th width="40%">${name}<span class="required-form-field">*</span>:</th>
      <td width="60%">$element</td>
    </tr>
EOQ

  return $ret;
}

package Sniglets::Forms::Style::kickstart;

use base qw/Sniglets::Forms::Style::standard/;

sub row {
  my $self = shift;
  my $label = shift;
  my $name = shift;
  my @elements = @_;

  my $element = join "<br/>\n", @elements;
  my $ret;

  if ($name) {
    $ret = <<EOQ;
    <tr>
      <th>${name}:</th>
      <td>$element</td>
EOQ
  }
  else {
    $ret = <<EOQ;
      <td>$element</td>
   </tr>
EOQ
}

  return $ret;
}

sub required_row {
  my $self = shift;
  my $label = shift;
  my $name = shift;
  my @elements = @_;

  my $element = join "<br/>\n", @elements;
  my $ret;

  if ($name) {
    $ret = <<EOQ;
    <tr>
      <th>${name}<span class="required-form-field">*</span>:</th>
      <td>$element</td>
EOQ
  }
  else {
    $ret = <<EOQ;
      <td>$element</td>
   </tr>
EOQ
  }

  return $ret;
}


# used for the System <-> Namespace control
package Sniglets::Forms::Style::namespace;

use base qw/Sniglets::Forms::Style::standard/;

sub rows_header {
  my $self = shift;
  my $name = shift;

  my $ret = <<EOQ;
  <table class="namespace-control">
    <tr>
EOQ

  return $ret;
}

sub rows_footer {
  my $self = shift;
  my $name = shift;

  my $ret = <<EOQ;
    </tr>
  </table>
EOQ

  return $ret;
}


sub control_column {
  my $self = shift;
  my @elements = @_;

  my $element = join "<br />\n", @elements;

  my $ret = <<EOQ;
      <td>$element</td>
EOQ

  return $ret;
}

sub column {
  my $self = shift;
  my $label = shift;
  my $name = shift;
  my @elements = @_;

  my $element = join "<br />\n", @elements;

  my $ret = <<EOQ;
      <td>$name:<br />$element</td>
EOQ

  return $ret;
}

sub required_row {
  my $self = shift;
  return $self->row(@_);
}

1;
