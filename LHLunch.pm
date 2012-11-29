#!/usr/bin/env perl
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-24 03:25:22

package LHLunch;

use feature ();
use strict;
use warnings;
use utf8;
use threads;

use Mojo::UserAgent;
use Mojo::JSON;
#use Mojo::Util 'encode';
use FindBin;
use Data::Dumper;

use lib "$FindBin::Bin";
use LHLunchConfig;

use constant STATE_BASE   => 0x0001;
use constant STATE_QUEUED => STATE_BASE << 1;
use constant STATE_READY  => STATE_BASE << 2;

sub new {
   return (bless({ src => [@LHLunchConfig::sources], state => STATE_BASE }, shift));
}

#sub _e {
#   return encode('UTF-8', shift);
#}

sub parse_restaurant {
   my $r  = shift;
   my $n  = $r->{name};
   my $u  = $r->{url};
   my $ua = Mojo::UserAgent->new();
   my $tx = $ua->get($u);
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
   return ($n, $u, [ map { { dish => $_->[0], desc => $_->[1], price => $_->[2] } } @d ]);
}

sub init {
   my $self = shift;
   async {
      foreach (@{ $self->{src} }) {
         threads->create({ context => 'list' }, 'parse_restaurant', $_);
      }
   }
   ->join();
   $self->{state} |= STATE_QUEUED;
}

sub scrape {
   my $self = shift;
   $self->init unless ($self->{state} & STATE_QUEUED);
   foreach (threads->list()) {
      my @r_data = $_->join();
      my $ret    = {
         name   => shift(@r_data),
         src    => shift(@r_data),
         date   => time,
         dishes => @r_data,
      };
      push(@{ $self->{menu} }, $ret);
   }
   $self->{state} |= STATE_READY;
}

sub clear {
   my $self = shift;
   $self->{menu}  = [];
   $self->{state} = STATE_BASE;
   return $self;
}

sub as_struct {
   my $self = shift;
   $self->scrape unless ($self->{state} & STATE_READY);
   return $self->{menu};
}

sub as_json {
   my $self = shift;
   $self->{json} //= Mojo::JSON->new;
   $self->scrape unless ($self->{state} & STATE_READY);
   return ($self->{json}->encode($self->{menu}));
}

sub as_xml {
   my $self = shift;
   return sprintf("TODO: implement %s::as_xml()", $$self)
}

#print("Data in JSON format: \n\n", __PACKAGE__->new->as_json, "\n") unless caller;
print(Dumper(__PACKAGE__->new->as_struct)) unless caller;;

1;
__END__
