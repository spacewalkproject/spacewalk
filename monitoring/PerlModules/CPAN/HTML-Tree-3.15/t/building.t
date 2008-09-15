
# -*-Perl-*-
# Time-stamp: "2000-05-18 23:57:15 MDT"

#Test that we can build and compare trees

use Test;
BEGIN { plan tests => 22 }

use HTML::Element 1.53;

my $t1;
{
  use strict;
  my $lol;
  $t1 = HTML::Element->new_from_lol(
     $lol =
     ['html',
      ['head',
       [ 'title', 'I like stuff!' ],
      ],
      ['body',
       {'lang', 'en-JP'},
       'stuff',
                 ['p', 'um, p < 4!', {'class' => 'par123'}],
       ['div', {foo => 'bar'}, '123'],  # at 0.1.2
      ]
     ]
    )
  ;

  ok $t1->content_list, 2;

  my $div = $t1->find_by_attribute('foo','bar');
  ok $div;

  ok $div->address, '0.1.2';
  ok $div eq $t1->address('0.1.2'); # using address to get the node
  ok $div->same_as($div);
  ok $t1->same_as($t1);
  ok not($div->same_as($t1));

  my $t2 = HTML::Element->new_from_lol($lol);
  ok $t2->same_as($t1);
  $t2->address('0.1.2')->attr('snap', 123);
  ok not($t2->same_as($t1));

  my $body = $t1->find_by_tag_name('body');
  ok $body->tag eq 'body';
  {
    my $cl = join '~', $body->content_list;
    my @detached = $body->detach_content;
    ok $cl eq join '~', @detached;
    $body->push_content(@detached);
    ok $cl eq join '~', $body->content_list;
  }

  $t2->delete;
}
$t1->delete if $t1;

Test2: # for normalization
{
  local($^W) = 0;
  $t1 = HTML::Element->new_from_lol(['p', 'stuff', ['hr'], 'thing']);
  my @start = $t1->content_list;
  ok @start eq 3;
  my $lr = $t1->content;
  splice @$lr,1,0, undef;
  push @$lr, undef;
  unshift @$lr, undef;

  #print "Content list:", join(',', map defined($_) ? $_ : '<UNDEF>', @$lr), "\n";

  ok $t1->content_list eq 6;
  ok join('~', @start) ne join('~', $t1->content_list);
  $t1->normalize_content;
  #print "Content list:", join(',', map defined($_) ? $_ : '<UNDEF>', @$lr), "\n";
  ok $t1->content_list eq 3;
  ok join('~', @start) eq join('~', $t1->content_list);


  ok ! defined $t1->attr('foo');
  $t1->attr('foo', 'bar');
  ok 'bar' eq $t1->attr('foo');
  ok scalar grep 'bar', $t1->all_external_attr();
  $t1->attr('foo', '');
  ok scalar grep 'bar', $t1->all_external_attr();
  $t1->attr('foo', undef); # should delete it
  ok not grep 'bar', $t1->all_external_attr();
  $t1->delete;
}
