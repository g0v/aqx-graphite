use v5.14;
use utf8;
use strict;
use YAML;
use Data::Dumper;
use Text::CSV;
use JSON::PP;
binmode STDOUT, ":utf8";

my %name_trans = ();
open my $fh, "<:utf8", "epa-site.csv";

my $csv = Text::CSV->new({ binary => 1 });
while (my $row = $csv->getline($fh)) {
    $name_trans{ $row->[1] } = $row->[0];
}

print Data::Dumper::Dumper(\%name_trans);
