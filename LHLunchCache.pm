#!/usr/bin/env perl
# Trying to lessen the request to the source servers.
# Many of the subs here are just proxies towards LHLunch.pm
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-29 23:33:05

package LHLunchCache;

use feature ();
use strict;
use warnings;
use utf8;

use Storable;
use DateTime;
use FindBin;
use lib "$FindBin::Bin";
use LHLunch;

my $_singleton;

sub new {
   my $class      = shift;
   my $cache_file = shift;
   return (
      $_singleton //= bless(
         {  lhl   => LHLunch->new,
            stamp => time,
            cfile => $cache_file
         },
         $class
      )
   );
}

sub stamp {
   my $self = shift;
   $self->{stamp} = shift if (@_);
   return $self->{stamp};
}

sub cache_file {
   my $self = shift;
   $self->{cfile} = shift if (@_);
   return $self->{cfile};
}

sub is_fresh {
	my ($dt_cache, $dt_cmp) = @_;	# assumed to be DateTime instances
	return ($dt_cache->ymd('') == $dt_cmp->ymd(''));	# within same day
}

sub cache {
   my $self      = shift;
   my $dt_parsed = DateTime->from_epoch(epoch => $self->{lhl}->stamp);
   my $dt_now    = DateTime->now;

   if ($self->{lhl}->ready) {
      if (!is_fresh($dt_parsed, $dt_now)) {    # midnight has passed
         $self->{lhl}->clear->scrape;
      }
   }
   else {
      if (-r $self->cache_file) {
         my $data;
         eval { $data = Storable::retrieve($self->cache_file) };
         if ($@) {
            $self->{lhl}->scrape;
         }
         else {
         		# need to check age here before just reloading...
         		my $dt_cache = DateTime->from_epoch(epoch => $data->[0]{date});
         		if (!is_fresh($dt_cache, $dt_now)) {
         			$self->{lhl}->scrape;
         		}
         		else {
            		$self->{lhl}->reload($data);
            	}
         }
      }
      else {
         $self->{lhl}->scrape;
      }
   }

   if ($self->stamp < $self->{lhl}->stamp) {
      $self->stamp($self->{lhl}->stamp);
      Storable::nstore($self->{lhl}{menu}, $self->cache_file);
   }

   return $self->{lhl}{menu};
}


1;
__END__

