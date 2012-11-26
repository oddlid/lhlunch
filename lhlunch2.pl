#!/usr/bin/env perl
# Odd Eivind Ebbesen, 2012-11-23 22:17:58

use strict;
use warnings;
use utf8;
use threads;

use Mojo::UserAgent;
use Mojo::JSON;
use Mojo::Util 'encode';
use Data::Dumper;

my @_dst;
my @_src = (
   {  name => q/Bistrot/,
      url  => 'http://www.lindholmen.se/sv/restaurang/bistrot',
   },
   {  name => q/Encounter Asian Cuisine/,
      url  => 'http://www.lindholmen.se/sv/restaurang/encounter-asian-cuisine',
   },
   {  name => q/Semcon/,
      url  => 'http://www.lindholmen.se/sv/restaurang/lindholmens-matsal-semcon',
   },
   {  name => q/Kooperativet/,
      url  => 'http://www.lindholmen.se/sv/restaurang/kooperativet',
   },
   {  name => q/L's Kitchen/,
      url  => 'http://www.lindholmen.se/sv/restaurang/ls-kitchen',
   },
   {  name => q/Mimolett/,
      url  => 'http://www.lindholmen.se/sv/restaurang/mimolett',
   },
   {  name => q/Gothia/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-gothia',
   },
   {  name => q/Göta Älv/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-gota-alv-ericssonshuset',
   },
   {  name => q/Restaurant R/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-r',
   },
   {  name => q/Tableau/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-tableau-tv-och-radiohuset',
   },
   {  name => q/Äran/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-aran',
   },
   {  name => q/Spacys/,
      url  => 'http://www.lindholmen.se/sv/restaurang/spacys-lindholmen',
   },
);

sub _parse_restaurant {
   my $r  = shift;
   my $n  = $r->{name};
   my $u  = $r->{url};
   my $ua = Mojo::UserAgent->new();
   my $tx = $ua->get($u);
   my @d;
   $tx->res->dom('tbody > tr > td[class*="views-field-title"]')->each(
      sub {
         my $e = shift;
         push(@d, [ encode('UTF-8', $e->children->first->text), encode('UTF-8', $e->text) ]);
      }
   );
   my @p = $tx->res->dom('tbody > tr > td[class*="views-field-field-price-value"]')->each;
   for (my $i = 0; $i < @p; $i++) {
      my $price = $p[$i]->text;
      $price =~ s/[^0-9]//g;
      push(@{ $d[$i] }, $price);
   }
   return ($n, $u, [ map { { dish => $_->[0], desc => $_->[1], price => $_->[2] } } @d ]);
}

async {
   foreach (@_src) {
      threads->create({ context => 'list' }, '_parse_restaurant', $_);
   }
}
->join();

foreach (threads->list()) {
   my @r_data = $_->join();
   my $struct = {
      name   => shift(@r_data),
      src    => shift(@r_data),
      date   => time,
      dishes => @r_data,
   };
   push(@_dst, $struct);
}

print(Dumper(\@_dst));

#my $_json = Mojo::JSON->new;
#my $_bytes = $_json->encode(\@_dst);
#print($_bytes, "\n");
