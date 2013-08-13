#!/usr/bin/env perl
# Displays results from LHLunch.pm in different web formats.
# Odd Eivind Ebbesen, 2012-11-27 15:49:35

use utf8;
# Automatically enables strict and warnings + 5.10 features
use Mojolicious::Lite;
use DateTime;
use Data::Dumper;
use FindBin;
use Text::Wrap;
use lib "$FindBin::Bin";
use LHLunchCache;

my $_lhlc; # delay creation

app->config(hypnotoad => { listen => ['http://*:3000'], proxy => 1 });
app->secret(qx(dd if=/dev/urandom bs=512 count=1));

get '/' => sub {
   my $self = shift;
   $self->render('index');
};

get '/lindholmen' => sub {
   my $self = shift;
   $_lhlc //= LHLunchCache->new('/tmp/lunchcache.dat');
   $self->stash(_lhlc => $_lhlc);

   $self->respond_to(
      json => { json => { encoding => 'utf8', restaurants => $_lhlc->as_struct } },
      txt => { template => 'lindholmen', format => 'txt' },
      any => { template => 'lindholmen', format => 'html' },
   );
};

app->start;

__DATA__

@@ lindholmen.txt.ep
% $Text::Wrap::columns = 72;
% my $struct = $_lhlc->as_struct;
% foreach my $r (@$struct) {
   % next unless (scalar(@{$r->{dishes}}) > 0);
   ---------------------------------------------------------------------------
   %= $r->{name}
   ---------------------------------------------------------------------------
   % foreach my $d (@{$r->{dishes}}) {
      %= Text::Wrap::wrap('', ' ' x 6, $d->{dish} . ' ' . $d->{desc})
      <%= $d->{price} %>,-

   %}
% }


@@ lindholmen.html.ep
% my $struct = $_lhlc->as_struct;
<!DOCTYPE html>
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <title>Lindholmen Lunch</title>
      <style type="text/css" media="screen">
         /*<![CDATA[*/
            body {
               font-family: sans-serif;
               font-size: 1.2em;
               background: #000;
            }
            div#content {
               background: #369;
               border-radius: 2em;
               padding: 2em;
            }
            h1.pghdr {
               color: #dd9;
            }
            div.restaurant {
               background: #eeb;
               border-radius: 2em;
               padding: 1em;
               margin-bottom: 0.7em;
            }
            div.restaurant h2.name {
               background: #69c;
               font-weight: bold;
               border-radius: 2em;
               padding: 0.8em;
            }
            h2.name a {
               color: #eee;
               font-size: 1.1em;
            }
            h2.name span.parsed {
               font-size: 0.5em;
               color: #eee;
               float: right;
            }
            h2.name span.parsed:before {
               content: "Parsed: ";
            }
            div.restaurant div.dishes {
               background: #9cf;
               border-radius: 2em;
               padding: 0.8em;
               margin-left: 2em;
            }
            div.dish {
               background: #369;
               color: #dd9;
               border-radius: 2em;
               padding: 0.7em;
               margin-bottom: 0.5em;
            }
            div.dish h3.name {
               color: #cf6;
               font-weight: bold;
               display: inline;
            }
            div.dish p.desc {
               display: inline;
            }
            div.dish span.price {
               font-size: 1.3em;
               float: right;
            }
            div.dish span.price:after {
               content: ",-";
            }
         /*]]>*/
      </style>
   </head>
   <body>
      <!-- Get the perl behind this at: https://github.com/oddlid/lhlunch -->
      <div id="content">
         <h1 class="pghdr">Lunch at Lindholmen today</h1>
         % foreach my $r (@$struct) {
            % next unless (scalar(@{$r->{dishes}}) > 0);
            % my $dt = DateTime->from_epoch(epoch => $r->{date});
            % my $dt_fmt = $dt->ymd('-') . ' ' . $dt->hms(':');
            <div class="restaurant">
            <h2 class="name">
               <a href="<%= $r->{url} %>"><%= $r->{name} %></a>
               <span class="parsed"><%= $dt_fmt %></span>
            </h2>
            <div class="dishes">
            % foreach my $d (@{$r->{dishes}}) {
               <div class="dish">
                  <h3 class="name"><%= $d->{dish} %></h3>
                  <p class="desc"><%= $d->{desc} %></p>
                  <span class="price"><%= $d->{price} %></span>
               </div> <!-- div dish -->
            % }
            </div>   <!-- div dishes -->
         </div>  <!-- div restaurant -->
         % }
      </div> <!-- div content -->
   </body>
</html>


@@ index.html.ep
<!DOCTYPE html>
<html>
   <head>
      <title>Lunch</title>
   </head>
   <body>
      <%= link_to 'Lindholmen (html)' => 'lindholmen.html' %><br />
      <%= link_to 'Lindholmen (text)' => 'lindholmen.txt' %><br />
      <%= link_to 'Lindholmen (json)' => 'lindholmen.json' %><br />
   </body>
</html>

__END__
