
#!/usr/bin/env perl
# Odd Eivind Ebbesen, 2012-09-20 13:55:28

# Pulls in strict, warnings and v5.10 features
use Mojolicious::Lite;
use Carp;
#use utf8;
#plugin 'TagHelpers';

get '/' => sub {
   my $self = shift;
   #$self->stash(_site => 'http://lyncon.se/dagens/lindholmen/');
   my $site = 'http://lyncon.se/dagens/lindholmen/';
   $self->render(data => $self->ua->get($site)->res->body);
   #$self->render('index');
};

app->start;


__DATA__

@@ index.html.ep
% title 'Lunch';
<!DOCTYPE html>
<html>
   <head>
      <title><%= title %></title>
   </head>
   <body>
      <%= content %>
   </body>
</html>
