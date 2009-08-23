#!/usr/bin/perl
# vim:set ts=8 sw=4 sts ai nu et:
use strict;
use warnings;
use Data::Dumper;
use Carp;

open(my $ofh, '>', 'output/dfd.html') or die $!;
print $ofh <<_;
<html>
<body>
<img src="dfd.png" usemap="#dfd">
_
open(my $ifh, '<', 'output/dfd-map.html') or die $!;
while (my $line = <$ifh>) {
    print $ofh $line;
}
close($ifh);
print $ofh <<_;
</body>
</html>
_
close($ofh);

__END__
