#!/usr/bin/perl
use strict;
use warnings;

if (!@ARGV && -t STDIN) { @ARGV = "mcu-registers.txt"; }

sub find_multibit_width {
	my ($rbits, $idx) = @_;
	my $width = 1;
	my $start = $idx;
	while ($start > 0 && substr($rbits->[$start - 1], 0, -1) eq substr($rbits->[$idx], 0, -1)) {
		$start--;
	}
	return $idx - $start;
}

while (<>) {
	print, next unless /^00/;
	chomp;
	my ($address, $name, $init, $rw, @bits) = split ' ';
	
	my @zero_idx = grep { $bits[$_] =~ /[^.]0$/ } 0..$#bits;
	if (@zero_idx) {
		my @widths = map { find_multibit_width(\@bits, $_) } @zero_idx;
		if (grep { $_ > 0 } @widths ) {
			#print STDERR "Detected multi-bit value on line $.: $_\n";
			for (0..$#widths) {
				my $end = $zero_idx[$_];
				my $start = $end - $widths[$_];
				if ($start != $end)
				{
					# change e.g. R07 to R0.7
					s/(.)$/\.$1/ for @bits[$start..$end];
				}
			}
			$_ = join(' ', $address, $name, $init, $rw, @bits);
		}	
	}	
	print $_, "\n";
}
