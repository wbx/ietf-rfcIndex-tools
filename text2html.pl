#!/usr/bin/perl
# vim:set ts=2 sw=2 ai:
use strict;
use warnings;
use IO::File;

my $url_rfcindex = 'http://www.ietf.org/download/rfc-index.txt';

my %class2pattern;
{
	my $re = qr{
		(?:
			[^()]*
			(?:
				\(
				[^()]*
				(?:
					\(
					[^()]*
					\)
					[^()]*
				)*
				\)
				[^()]*
			)*
		)
	}x;
	%class2pattern = (
		st => qr{\(Status:[^)]*\)}o,
		up => qr{\(Updates$re\)}o,
		upb => qr{\(Updated\s+by$re\)}o,
		ob => qr{\(Obsoletes$re\)}o,
		obb => qr{\(Obsoleted\s+by$re\)}o,
		fmt => qr{\(Format:[^)]*\)}o,
		als => qr{\(Also\s+[^)]*\)}o,
		date => qr{
			\b
			(?:
				(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)-\d+-\d+
			|
				(?:january|february|march|april|may|june|july|august|
				september|october|november|december)\s+\d+
			)\.
		}ixo,
	);
}

my $wfh = IO::File->new("> output/rfc-index.html.tmp") or die;

my $date = scalar localtime;
print $wfh <<__HTML_HEADER__;
<html>
<head>
<title>RFC INDEX (generated at $date)</title>
<link rel="stylesheet" href="./rfc-index.css">
</head>
<body>
<a href="$url_rfcindex">$url_rfcindex</a>
<pre>
__HTML_HEADER__

my $rfh = IO::File->new('< ./output/rfc-index.txt') or die;
{
	local $/ = "";
	local $| = 1; # no buffering

	for (0..1) {
		while (my $record = <$rfh>) {
			print $wfh $record;
			last if $record =~ /RFC INDEX/;
		}
	}

	my @records;
	while (my $rec = <$rfh>) {
		push @records, $rec;
	}

	my $rfc_number_old = 0;
	for (my $i = 0; $i < @records; $i++) {
		#my ($rfc_number, $title) = $records[$i] =~ m!^(\d+)\s+([^.]+)\.!s; # bad for processing rfc3675.
		#my ($rfc_number, $title) = $records[$i] =~ m!^(\d+)\s+(\.?[^.]+)\.!s; # bad for processing rfc0016.
		#my ($rfc_number, $title) = $records[$i] =~ m!^(\d+)\s+(\.?[^.]+)\.\s!s; # bad for processing rfc0015.
		#my ($rfc_number, $title) = $records[$i] =~ m!^(\d+)\s+(\.?[^.]+)\.(?:\s|$)!s; # bad for processing rfc0016.
		#my ($rfc_number, $title) = $records[$i] =~ m!^(\d+)\s+((?:\.\S|[^.])+)\.!s;
		$records[$i] =~ s!^(\d+)(\s+)((?:\.\S|[^.])+)\.!qq{<a href="http://www.faqs.org/rfcs/rfc}.($1+0).qq{.html"><span class="no1">$1</span></a>$2<span class="ttl"><a name="rfc$1">$3</a></span>}!es;
		my ($rfc_number, $title) = ($1, $3);
		my $title_attr = "";
		if (defined $title) {
			$title =~ s/\s+/ /g;
			my $safe_title = $title;
			$safe_title =~ s/&/&amp;/g;
			$safe_title =~ s/"/&quot;/g;
			$safe_title =~ s/</&lt;/g;
			$safe_title =~ s/>/&gt;/g;
			$title_attr = qq{ title="$safe_title"};
		} else {
			print "[warning $rfc_number (after: $rfc_number_old)]";
			($rfc_number) = $records[$i] =~ m!^(\d+)!o;
		}

		for (my $j = 0; $j < @records; $j++) {
			$records[$j] =~ s!RFC$rfc_number!<a href="#rfc$rfc_number"$title_attr><span class="no2">$&</span></a>!g;
		}

		if ($i % 100 == 0) {
			if ($i % 500) {
				print '.';
			} else {
				printf q{%d(%d)}, $i, $rfc_number;
			}
		}

		$rfc_number_old = $rfc_number;
	}
	printf qq{%d(%d)\n}, scalar(@records), $rfc_number_old;

	for my $rec (@records) {
		my $out;
		if ($rec =~ /\(not\s+online\)/i or $rec =~ /Not Issued/) {
			$out = qq{<div class="ci"><div class="nava">*$rec</div></div>\n};
		} else {
			while (my ($class, $pattern) = each %class2pattern) {
				$rec =~ s!($pattern)!<span class="$class">$1</span>!sg;
			}
			$out = qq{<div class="ci">*$rec</div>\n};
		}
		$out =~ s/^(\s+)/ $1/mg;

		print $wfh $out;
	}
}
$rfh->close;

print $wfh <<__HTML_FOOTER__;
</pre>
</body>
</html>
__HTML_FOOTER__

$wfh->close;

# .html.tmp --> .html
if (-f qq{output/rfc-index.html}) {
	unlink qq{output/rfc-index.html} or die $!;
}
rename qq{output/rfc-index.html.tmp}, qq{output/rfc-index.html} or die $!;
system('cp ./rfc-index.css ./output');

__END__
