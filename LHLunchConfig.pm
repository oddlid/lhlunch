# cfg-file-as-a-module
# Just add/edit/delete entries in @sources if you want to change the list.
#
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-24 03:17:38

package LHLunchConfig;

use utf8;
use Mojo::UserAgent;

#my $parser = sub {
#   my $r  = shift;
#   my $ua = Mojo::UserAgent->new;
#   my $tx = $ua->get($r->{url});
#   my @d;
#   $tx->res->dom('tbody > tr > td[class*="views-field-title"]')->each(
#      sub {
#         my $e = shift;
#         push(@d, [ $e->children->first->text, $e->text ]);
#      }
#   );
#   my @p = $tx->res->dom('tbody > tr > td[class*="views-field-field-price-value"]')->each;
#   for (my $i = 0; $i < @p; $i++) {
#      my $price = $p[$i]->text;
#      $price =~ s/[^0-9]//g;
#      push(@{ $d[$i] }, $price);
#   }
#   return ($r->{name}, $r->{url}, [ map { { dish => $_->[0], desc => $_->[1], price => $_->[2] } } @d ]);
#};

# New URL format:
# http://www.lindholmen.se/pa-omradet/dagens-lunch?type=All&date%5Bvalue%5D%5Byear%5D=2014&date%5Bvalue%5D%5Bmonth%5D=2&date%5Bvalue%5D%5Bday%5D=5&restaurant=143
# 

sub geturl {
   my $restaurant_id = shift;
   my $dt            = DateTime->now;
   my %u = (
      '[' => '%5B',
      ']' => '%5D',
   );
   my $url = 'https://www.lindholmen.se/pa-omradet/dagens-lunch?';
   my $q   = sprintf(
      "type=All&date%svalue%s%syear%s=%d&date%svalue%s%smonth%s=%d&date%svalue%s%sday%s=%d&restaurant=%d",
      $u{'['}, $u{']'},    $u{'['}, $u{']'}, $dt->year, $u{'['}, $u{']'},  $u{'['},
      $u{']'}, $dt->month, $u{'['}, $u{']'}, $u{'['},   $u{']'}, $dt->day, $restaurant_id
   );
   return $url . $q;
}

my $parser = sub {
   my $r   = shift;
   my $ua  = Mojo::UserAgent->new;    # should make the sub get this from the outside, for reuse
   my $url = geturl($r->{rid});
   my $tx  = $ua->get($url);
   my @d;

   $tx->res->dom('span[class="dish-name"]')->each(
      sub {
         my $e = shift;
         push(@d, [ $e->children->first->text, $e->text ]);
      }
   );
   my @p = $tx->res->dom('div[class="table-list__column table-list__column--price"]')->each;
   for (my $i = 0; $i < @p; $i++) {
      my $price = $p[$i]->text;
      $price =~ s/[^0-9]//g;
      push(@{ $d[$i] }, $price);
   }
   return ($r->{name}, $url, [ map { { dish => $_->[0], desc => $_->[1], price => $_->[2] } } @d ]);
};

our @sources = (
   {  name   => q/Lindholmens Matsal/,
      #url    => 'http://www.lindholmen.se/restauranger/lindholmens-matsal',
      rid    => 137,
      parser => $parser,
   },
   {  name   => q/Bistrot/,
      #url    => 'http://www.lindholmen.se/restauranger/bistrot',
      rid    => 129,
      parser => $parser,
   },
   {  name   => q/Sweet and sour/,
      #url    => 'http://www.lindholmen.se/restauranger/sweet-and-sour',
      rid    => 152,
      parser => $parser,
   },
   {  name   => q/Kooperativet/,
      #url    => 'http://www.lindholmen.se/restauranger/kooperativet',
      rid    => 142,
      parser => $parser,
   },
   {  name   => q/Mimolett/,
      #url    => 'http://www.lindholmen.se/restauranger/mimolett',
      rid    => 143,
      parser => $parser,
   },
   {  name   => q/Äran/,
      #url    => 'http://www.lindholmen.se/restauranger/restaurang-aran',
      rid    => 139,
      parser => $parser,
   },
   {
      name   => q/Matminnen/,
      #url    => 'http://www.lindholmen.se/restauranger/matminnen',
      rid    => 17933,
      parser => $parser,
   },
   {  name   => q/Cuckoo's Nest/,
      #url    => 'http://www.lindholmen.se/restauranger/cuckoos-nest',
      rid    => 157,
      parser => $parser,
   },
   {  name   => q/Tableau/,
      #url    => 'http://www.lindholmen.se/restauranger/restaurang-tableau-tv-och-radiohuset',
      rid    => 125,
      parser => $parser,
   },
   {  name   => q/L's Kitchen/,
      #url    => 'http://www.lindholmen.se/restauranger/ls-kitchen',
      rid    => 147,
      parser => $parser,
   },
   {  name   => q/Encounter Asian Cuisine/,
      #url    => 'http://www.lindholmen.se/restauranger/encounter-asian-cuisine',
      rid    => 141,
      parser => $parser,
   },
   {  name   => q/Gothia/,
      #url    => 'http://www.lindholmen.se/restauranger/restaurang-gothia',
      rid    => 128,
      parser => $parser,
   },
   {  name   => q/Pir 11 (Ericsson-huset)/,
      #url    => 'http://www.lindholmen.se/restauranger/pir-11-ericsson-huset',
      rid    => 151,
      parser => $parser,
   },
);


1;
__END__
