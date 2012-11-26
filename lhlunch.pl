#!/usr/bin/env perl
# Odd Eivind Ebbesen, 2012-11-22 09:25:22

use strict;
use warnings;
use utf8;
use threads;

use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util 'encode';
use Data::Dumper;

#my $url = 'http://www.lindholmen.se/sv/dagens-lunch';
#my $r = {}; # container for all info gathered
#my $cur;

my @restaurants = (
#   {  name   => q/Bistrot/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/bistrot',
#      dishes => [
##         {  name  => undef,
##            desc  => undef,
##            price => 0
##         },
#      ]
#   },
#   {  name   => q/Encounter Asian Cuisine/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/encounter-asian-cuisine',
#      dishes => []
#   },
#   {  name   => q/Semcon/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/lindholmens-matsal-semcon',
#      dishes => []
#   },
#   {  name   => q/Kooperativet/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/kooperativet',
#      dishes => []
#   },
#   {  name   => q/L's Kitchen/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/ls-kitchen',
#      dishes => []
#   },
#   {  name   => q/Mimolett/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/mimolett',
#      dishes => []
#   },
#   {  name   => q/Gothia/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-gothia',
#      dishes => []
#   },
#   {  name   => q/Göta Älv/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-gota-alv-ericssonshuset',
#      dishes => []
#   },
   {  name   => q/Restaurant R/,
      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-r',
      dishes => []
   },
#   {  name   => q/Tableau/,
#      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-tableau-tv-och-radiohuset',
#      dishes => []
#   },
   {  name   => q/Äran/,
      url    => 'http://www.lindholmen.se/sv/restaurang/restaurang-aran',
      dishes => []
   },
   {  name   => q/Spacys/,
      url    => 'http://www.lindholmen.se/sv/restaurang/spacys-lindholmen',
      dishes => []
   },
);

my $ua = Mojo::UserAgent->new();
my @tasks;
foreach (@restaurants) {
   my $name   = $_->{name};
   my $url    = $_->{url};
   my $dishes = $_->{dishes};
   print($name, "\n");
   push(
      @tasks,
      sub {
         #my $delay = shift;
         print("Parsing URL: $url\n");
         my $tx    = $ua->get($url);
         $tx->res->dom('tbody > tr > td[class*="views-field-title"]')->each(
            sub {
               my $e = shift;
               printf(qq(Parsing dish "%s"...\n), $e->children->first->text);
               push(@{$dishes}, [ encode('UTF-8', $e->children->first->text), encode('UTF-8', $e->text), ]);
            }
         );
         my @prices = $tx->res->dom('tbody > tr > td[class*="views-field-field-price-value"]')->each;
         for (my $i = 0; $i < @prices; $i++) {
            push(@{$dishes->[$i]}, $prices[$i]->text);
         }
      }
   );
}

my $_delay = Mojo::IOLoop->delay(sub { print("Weeeeeee!\n") });
$_delay->steps(@tasks);
##$_delay->begin(undef, $_) for (@tasks);
my @ret = $_delay->wait unless Mojo::IOLoop->is_running;
print(Dumper(\@ret));
print(Dumper(\@restaurants));


sub get_dishes {
   my $url    = shift;
   my $dishes = shift;    # must be array ref
                          #my @elems  = $ua->get($url)->res->dom('tbody > tr > td, td > strong')->uniq->each;
#   $ua->get(
#      $url => sub {
#         my ($ua, $tx) = @_;
#         $tx->res->dom('tbody > tr > td[class*="views-field-title"]')->each(
#            sub {
#               my $e = shift;
##               print($e->text, "\n");
#               push(@{$dishes},
#                  [
#                     encode('UTF-8', $e->children->first->text),
#                     encode('UTF-8', $e->text),
#                  ]
#               );
#            }
#         );
#
#      }
#   );
#   my $tx     = $ua->get($url);
#   $tx->res->dom('tbody > tr > td[class*="views-field-title"]')->each(
#      sub {
#         my $e     = shift;
#         my $title = encode('UTF-8', $e->children->first->text);
#         my $desc  = encode('UTF-8', $e->text);
#         push(@{$dishes}, [ $title, $desc ]);
#      }
#   );
#
#   my @prices = $tx->res->dom('tbody > tr > td[class*="views-field-field-price-value"]')->each;
#   for (my $i = 0; $i < @{$dishes}; $i++) {
#      push(@{ $dishes->[$i] }, $prices[$i]->text);
#   }

#   $ua->get($url => $delay->begin(undef, $url, $dishes));

   #my @descs_enc = map { encode('UTF-8', $_->all_text) } @descs;
   #print(Dumper(@descs_enc));

#   my @names  = $tx->res->dom('tbody > tr > td[class*="views-field-title"] > strong')->each;

#   for (my $i = 0; $i < @names; $i++) {
#      print(encode('UTF-8', $names[$i]->text), " ");
#      print(join("===", map { encode('UTF-8', $_->text) } @descs), "\n");
#      print($prices[$i]->text);
##      for (my $j = 0; $j < @descs; $j++) {
##         print(encode('UTF-8', $descs[$j]->text), "\n\t");
##         print($prices[$j]->text, "\n");
##      }
#      print("\n");
#   }

   #print($_->text, "\n") for (@names);
   #print(Dumper(\@names, \@prices, \@descs));
#   my %dish = ();

#   foreach (@elems) {
#      my $type = $_->type;
#      my $text = $_->text;
#      $text =~ s/^\s+//;
#      $text =~ s/\s+$//;
#      next if ($text eq '');
#      if ($type eq 'strong') {
#         $dish{name} = $text; #encode('UTF-8', $text);
#      }
#      elsif ($text =~ /^[0-9]+/) {
#         $dish{price} = $text;
#      }
#      elsif ($text =~ /[a-zA-Z0-9]+/) {
#         $dish{desc} = $text; #encode('UTF-8', $text);
#      }
#      else {
#         next;
#      }
#      push(@{$dishes}, [%dish]);
#   #%dish = ();
#   }

#   $ua->get($url)->res->dom('tbody > tr > td, td > strong')->uniq->each(
#      sub {
#         my $e = shift;
#         #print(Dumper($e));
#         my $type = $e->type;
#         my $text = $e->text;
#         #return if ($text eq '');
#         $text =~ s/^\s+//;
#         $text =~ s/\s+$//;
#         my $dish = {};
#         if ($type eq 'strong') {
#            $dish->{name} = encode('UTF-8', $text);
#         }
#         elsif ($type eq 'td') {
#            if ($text =~ /^[0-9]+/) {
#               $dish->{price} = $text;
#            }
#            else {
#               $dish->{desc} = encode('UTF-8', $text);
#            }
#         }
#         push(@{$dishes}, [$dish]);
#         undef($dish);
#        }
#   );
}

#Mojo::IOLoop->on(finish => sub {
#      print(Dumper(@restaurants));
#   });
#foreach (@restaurants) {
#   get_dishes($_->{url}, $_->{dishes});
#}
#Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
#
#print(Dumper(@restaurants));

# This part should be done async
#foreach (map { get_dishes($_->{url}, $_->{dishes}) } @restaurants) {
#   #..
#}

#my $elems = $ua->get($url)->res->dom('tbody a, td, strong')->uniq;
#$elems->each(sub {
#      my $e = shift;
#      return if ($e->text eq '');
#      #print("Type: ", $e->type, "\n");
#      if ($e->type eq 'a') {
#         #print("Restaurant: ", $e->all_text, "\n");
#         $cur = $e->all_text;
#      }
#      elsif ($e->type eq 'strong') {
#         push(@{$r->{$cur}{dishes}}, $e->text);
#      }
##      elsif ($e->type eq 'td') {
##         #print("\t", encode('UTF-8', $e->all_text), "\n");
##         if ($e->text =~ /^0-9+/) {
##            $r->{$cur}{price}
##         }
##      }
#   });
#print(Dumper($r));



#$ua->get($url)->res->dom('tbody a, td')->each(sub { 
#   while (shift) {
#      print("Elem: ", $_, "\n");
#      print("Type: ", $_->type, "\n---\n");
#   }
#});
