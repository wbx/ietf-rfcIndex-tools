#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Carp;

my $wget = '/usr/bin/wget';
my $wget_output_file = './output/rfc-index.txt';
my $url = 'http://www.ietf.org/download/rfc-index.txt';

system($wget, '-NO', $wget_output_file, $url) == 0 or die $!;

my $size = -s $wget_output_file;
die "output file is too short" if $size < 1024 * 100;

__END__
