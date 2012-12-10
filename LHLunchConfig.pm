# cfg-file-as-a-module
# Just add/edit/delete entries in @sources if you want to change the list.
#
# Odd Eivind Ebbesen <odd@oddware.net>, 2012-11-24 03:17:38

package LHLunchConfig;

our @sources = (
   {  name => q/Bistrot/,
      url  => 'http://www.lindholmen.se/sv/restaurang/bistrot',
   },
   {  name => q/Encounter Asian Cuisine/,
      url  => 'http://www.lindholmen.se/sv/restaurang/encounter-asian-cuisine',
   },
   {  name => q/Semcon/,
      url  => 'http://www.lindholmen.se/sv/restaurang/lindholmens-matsal-semcon',
   },
   {  name => q/Kooperativet/,
      url  => 'http://www.lindholmen.se/sv/restaurang/kooperativet',
   },
   {  name => q/L's Kitchen/,
      url  => 'http://www.lindholmen.se/sv/restaurang/ls-kitchen',
   },
   {  name => q/Mimolett/,
      url  => 'http://www.lindholmen.se/sv/restaurang/mimolett',
   },
   {  name => q/Gothia/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-gothia',
   },
   {  name => q/Göta Älv/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-gota-alv-ericssonshuset',
   },
   {  name => q/Restaurant R/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-r',
   },
   {  name => q/Tableau/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-tableau-tv-och-radiohuset',
   },
   {  name => q/Äran/,
      url  => 'http://www.lindholmen.se/sv/restaurang/restaurang-aran',
   },
   {  name => q/Spacys/,
      url  => 'http://www.lindholmen.se/sv/restaurang/spacys-lindholmen',
   },
);

1;
__END__
