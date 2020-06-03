#!/usr/bin/perl
use strict;
use warnings;

# annotate vectors


@ARGV or !-t STDIN or die "$0 file.a51\n";

my %vectors;
while (<DATA>) {
		chomp;
		my ($address, $source, $enable, $irq, $description) = split / /, $_, 5;
		$address =~ s/[Hh]$//;
		my $label;
		if ($irq =~ /[A-Z]/) {
				$label = uc($irq) . '_IRQVEC';
		} else {
				$label = uc($source) . '_VEC';
		}
		if ($description !~ /[A-Z]/) { $description = $source; $label .= "_$address"; };
		$vectors{$address} = { source => $source, enable => $enable, irq => $irq, description => $description, label => $label };
}

while (<>) {
	# first lesson: ignore DB values, ew
	if (/^\s*([0-9A-F]{4})/ && exists $vectors{$1}) {
		my $address = $1;
		my $info = $vectors{$address};
		print "\n";
		print "; ====================================\n";
		print "\n";
		print "; $info->{description}\n";
		print "\n";
		print "$info->{label}:\n";
	}
	print;
}
		
__END__
0000H Reset - - System Reset
0003H External_Interrupt0 IE.0 EXT0 P4.6 Falling Edge
000BH Base_Timer0 IE.1 T0 Base Timer0 Interrupt
0013H Reserved - - -
001BH Base_Timer1 IE.3 T1 Base Timer1 Interrupt
0023H Time_Capture_Interrupt0 IE.4 TC0 Time Capture0 Interrupt
002BH Reserved - - -
0033H Reserved - - -
0043H Setup_Interrupt IE2.0 STUP SETUP Token Interrupt
004BH OWSTUP_Interrupt IE2.1 OWSTUP -
0053H OT0ERR_Interrupt IE2.2 OT0ERR -
005BH IN0_Interrupt IE2.3 IN0 IN0 Token Interrupt
0063H OUT0_Interrupt IE2.4 OUT0 OUT0 Token Interrupt
006BH SIE_Interrupt IE2.5 SIE NAKT0, NAKR0, T0STL, R0STL, NAK1, NAK2, IN1, IN2
0073H Suspend/OVL_Interrupt IE2.6 FUN SUSP/OVL Interrupt
007BH Reserved - - -
