#!/usr/bin/env perl
# Intended to be run by a cron job or similar once a day, and
# save the results in a json file that can be statically served.
# Uses LHLunch.pm to obtain the results.
#
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-26 11:40:01

use strict;
use warnings;

use Getopt::Long;
use FindBin;
use FileHandle;

use lib "$FindBin::Bin";
use LHLunch;


my $_lhl;
my $_opts = { ofile => '/tmp/lunch.json' };

sub usage {
   print(STDERR "Usage: $0 ... \n");
   return 1;
}

sub scrape {
   my $fh = shift;
   $_lhl = LHLunch->new() unless ($_lhl);
   my $res = $_lhl->as_json();
   $fh->print($res);
}

GetOptions(
   "output" => \$_opts->{ofile},
   "help"   => sub { usage; exit 0; },
) or usage and exit 1;

if ($_opts->{ofile} eq '-') {
   scrape(FileHandle->new_from_fd(\*STDOUT));
}
else {
   scrape(FileHandle->new(">$_opts->{ofile}"));
}

__END__

