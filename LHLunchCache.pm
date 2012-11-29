#!/usr/bin/env perl
# Trying to lessen the request to the source servers
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-29 23:33:05

package LHLunchCache;

use strict;
use warnings;

use FileHandle;
use FindBin;
use lib "$FindBin::Bin";
use LHLunch;

use constant STATE_BASE => 0x0001;

my $_singleton;

sub new {
   return ($_singleton //= bless({ lhl => LHLunch->new() }, shift));
}

sub lhl {
   return $_[0]->{lhl};
}

sub clear {
   my $self = shift;
   $self->lhl()->clear();
   return $self;
}


