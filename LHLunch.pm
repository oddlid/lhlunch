#!/usr/bin/env perl
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-24 03:25:22

package LHLunch;

use feature ();
use strict;
use warnings;
use utf8;
use threads;

use Mojo::UserAgent;
use FindBin;
#use Data::Dumper;

use lib "$FindBin::Bin";
use LHLunchConfig;

use constant STATE_BASE   => 0x0001;
use constant STATE_QUEUED => STATE_BASE << 1;
use constant STATE_READY  => STATE_BASE << 2;

sub new {
   return (
      bless(
         {  src   => [@LHLunchConfig::sources],
            state => STATE_BASE,
            menu  => undef,
            born  => time,
            stamp => time
         },
         shift
      )
   );
}

sub stamp {
   my $self = shift;
   $self->{stamp} = shift if (@_);
   return $self->{stamp};
}

sub menu {
   my $self = shift;
   $self->{menu} = shift if (@_);
   return $self->{menu};
}

# Note, this sub is NOT object oriented!
# As it does not access other data than what it gets passed, 
# this part could be moved away and set to a callback/code ref defined by 
# the subscribing module. This way, it could be easier to adjust the parsing 
# depending on the format of the HTML source from the websites.
# ...
sub parse_restaurant {
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
}

sub init {
   my $self = shift;
   async {
      foreach (@{ $self->{src} }) {
         threads->create({ context => 'list' }, 'parse_restaurant', $_);
      }
   }
   ->join;
   $self->{state} |= STATE_QUEUED;
   return $self;
}

sub scrape {
   my $self = shift;
   $self->init unless ($self->{state} & STATE_QUEUED);
   my $ret;    # want to save an instance for after the loop
   foreach (threads->list) {
      my @r_data = $_->join;
      $ret = {
         name   => shift(@r_data),
         url    => shift(@r_data),
         date   => time,
         dishes => @r_data,
      };
      push(@{ $self->{menu} }, $ret);
   }
   $self->{state} |= STATE_READY;
   $self->stamp($ret->{date});    # date of last page parsed
   return $self;
}

sub clear {
   my $self      = shift;
   $self->{menu} = shift;    # possible to pass a new menu here, or it's undef/reset by default
   if (!ref($self->{menu})) {
      $self->{state} = STATE_BASE;
   }
   else {
      $self->{state} |= STATE_READY;
   }
   return $self;
}

sub reload {
   # Call this with no param, and the object is just reset, OR:
   # Pass a menu structure to start from saved state
   my $self = shift;
   return $self->clear(shift);
}

sub ready {
   my $self = shift;
   return ($self->{state} & STATE_READY && ref($self->{menu}) eq 'ARRAY');
}

#sub as_struct {
#   my $self = shift;
#   $self->scrape unless ($self->{state} & STATE_READY);
#   return $self->{menu};
#}
#
#sub as_json {
#   my $self = shift;
#   $self->{json} //= Mojo::JSON->new;
#   return ($self->{json}->encode($self->as_struct()));
#}
#
#print(Dumper(__PACKAGE__->new->as_struct)) unless caller;

1;
__END__
