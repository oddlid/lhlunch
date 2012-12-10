#!/usr/bin/env perl
# Displays results from LHLunch.pm in different web formats.
# Odd Eivind Ebbesen, 2012-11-27 15:49:35

# Automatically enables strict and warnings + 5.10 features
use Mojolicious::Lite;
use DateTime;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin";
use LHLunchCache;

my $_lhlc; # delay creation

app->config(hypnotoad => { listen => ['http://127.0.0.1:3000'] });

get '/lunch' => sub {
   my $self = shift;
   $self->render('index');
};

get '/lunch/lindholmen' => sub {
   my $self = shift;
   $_lhlc //= LHLunchCache->new('/tmp/lunchcache.dat');
   $self->stash(_lhlc => $_lhlc);

   $self->respond_to(
      json => sub { $self->render_json($_lhlc->cache) },
      txt => { template => 'lindholmen', format => 'txt' },
      any => { template => 'lindholmen', format => 'html' },
   );
};

app->start;

__DATA__

@@ lindholmen.txt.ep
% my $struct = $_lhlc->cache;
% foreach my $r (@$struct) {
   -----------------------------------------------------------------------
   %= $r->{name}
   -----------------------------------------------------------------------
   % foreach my $d (@{$r->{dishes}}) {
      %= $d->{dish}
      %= $d->{desc}
      <%= $d->{price} %>,-

   %}
% }

@@ lindholmen.html.ep
% my $struct = $_lhlc->cache;
<!DOCTYPE html>
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <title>Lindholmen Lunch</title>
   </head>
   <body>
      <!-- Get the perl behind this at: https://github.com/oddlid/lhlunch -->
      <ul>
      % foreach my $r (@$struct) {
         <li><%= link_to $r->{url} => begin %><%= $r->{name} %><% end %></li>
         <ul>
         % foreach my $d (@{$r->{dishes}}) {
            <li><strong><%= $d->{dish} %></strong> 
               <%= $d->{desc} %><br />
               <%= $d->{price} %>,-
            </li>
         % }
         </ul>
      % }
      </ul>
      <div>
         Last updated: <%= DateTime->from_epoch(epoch => $_lhlc->stamp)->datetime %>
      </div>
   </body>
</html>

@@ index.html.ep
<!DOCTYPE html>
<html>
   <head>
      <title>Lunch</title>
   </head>
   <body>
      %= link_to Lindholmen => 'lindholmen'
   </body>
</html>

__END__
