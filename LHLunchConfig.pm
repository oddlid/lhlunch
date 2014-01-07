# cfg-file-as-a-module
# Just add/edit/delete entries in @sources if you want to change the list.
#
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-24 03:17:38

package LHLunchConfig;

use utf8;
use Mojo::UserAgent;

my $parser = sub {
   my $r  = shift;
   my $ua = Mojo::UserAgent->new;
   my $tx = $ua->get($r->{url});
   my @d;
   $tx->res->dom('tbody > tr > td[class*="views-field-title"]')->each(
      sub {
         my $e = shift;
         push(@d, [ $e->children->first->text, $e->text ]);
      }
   );
   my @p = $tx->res->dom('tbody > tr > td[class*="views-field-field-price-value"]')->each;
   for (my $i = 0; $i < @p; $i++) {
      my $price = $p[$i]->text;
      $price =~ s/[^0-9]//g;
      push(@{ $d[$i] }, $price);
   }
   return ($r->{name}, $r->{url}, [ map { { dish => $_->[0], desc => $_->[1], price => $_->[2] } } @d ]);
};

our @sources = (
   {  name   => q/Bistrot/,
      url    => 'http://www.lindholmen.se/sv/restaurang/bistrot',
      parser => $parser,
   },
   {  name   => q/Encounter Asian Cuisine/,
      url    => 'http://www.lindholmen.se/sv/restaurang/encounter-asian-cuisine',
      parser => $parser,
   },
   {  name   => q/Semcon/,
      url    => 'http://www.lindholmen.se/sv/restaurang/lindholmens-matsal-semcon',
      parser => $parser,
   },
   {  name   => q/Kooperativet/,
      url    => 'http://www.lindholmen.se/sv/restaurang/kooperativet',
      parser => $parser,
   },
   {  name   => q/L's Kitchen/,
      url    => 'http://www.lindholmen.se/sv/restaurang/ls-kitchen',
      parser => $parser,
   },
   {  name   => q/Mimolett/,
      url    => 'http://www.lindholmen.se/sv/restaurang/mimolett',
      parser => $parser,
   },
   {  name   => q/Gothia/,
      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-gothia',
      parser => $parser,
   },
   {  name   => q/Göta Älv/,
      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-gota-alv-ericssonshuset',
      parser => $parser,
   },
   {  name   => q/Restaurant R/,
      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-r',
      parser => $parser,
   },
   {  name   => q/Tableau/,
      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-tableau-tv-och-radiohuset',
      parser => $parser,
   },
   {  name   => q/Äran/,
      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-aran',
      parser => $parser,
   },
   {  name   => q/Sweet and sour/,
      url    => 'http://www.lindholmen.se/sv/restaurang/sweet-and-sour',
      parser => $parser,
   },
);

1;
__END__
