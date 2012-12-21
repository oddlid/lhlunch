#!/usr/bin/env perl
# Intended to be run by a cron job or similar once a day, and
# save the results in a json file that can be statically served.
# Uses LHLunch.pm to obtain the results.
#
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-26 11:40:01

use feature ();
use strict;
use warnings;
use utf8;

use Getopt::Long;
use FindBin;
use FileHandle;
use Mojo::JSON;

use lib "$FindBin::Bin";
use LHLunchCache;


my $_opts = { 
   ofile => '/tmp/lunch.json',
   cfile => '/tmp/lunchcache.dat'
};

sub usage {
   print(STDERR "Usage: $0 [ --output=<path> --cache=<path> ] \n");
   return 1;
}

sub scrape {
   my $fh   = shift;
   my $lhlc = LHLunchCache->new($_opts->{cfile});
   my $json = Mojo::JSON->new;
   $fh->print($json->encode($lhlc->cache));
}

GetOptions(
   "output=s" => \$_opts->{ofile},
   "cache=s"  => \$_opts->{cfile},
   "help"     => sub { usage; exit 0; },
) or usage and exit 1;

if ($_opts->{ofile} eq '-') {
   scrape(FileHandle->new_from_fd(\*STDOUT));
}
else {
   scrape(FileHandle->new(">$_opts->{ofile}"));
}

__END__

