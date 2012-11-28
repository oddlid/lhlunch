#!/usr/bin/env perl
# Displays results from LHLunch.pm in different web formats.
# Odd Eivind Ebbesen, 2012-11-27 15:49:35

# Automatically enables strict and warnings + 5.10 features
use Mojolicious::Lite;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin";
use LHLunch;

my $_lhl; # delay creation

get '/lunch' => sub {
   my $self = shift;
   $self->render('index');
};

# trying new variant
get '/lunch/lindholmen' => sub {
   my $self = shift;
   $_lhl //= LHLunch->new;
   $self->stash(_lhl => $_lhl);

   $self->respond_to(
      json => sub { $self->render_json($_lhl->as_struct) },
      txt => { template => 'lindholmen', format => 'txt' },
      any => { template => 'lindholmen', format => 'html' },
   );
};

app->start;

__DATA__

@@ lindholmen.txt.ep
% my $struct = $_lhl->as_struct;
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
<!DOCTYPE html>
<html>
   <head>
      <title>Lindholmen Lunch</title>
   </head>
   <body>
      Not ready...
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
