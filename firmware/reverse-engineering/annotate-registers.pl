#!/usr/bin/perl
use strict;
use warnings;	
use File::Spec;

# annotate named register accesses

@ARGV or !-t STDIN or die "$0 file.a51\n";

my $mcu_registers_txt = File::Spec->catpath( 	(File::Spec->splitpath($0))[0..1], 'mcu-registers.txt' );

sub words;
my %labels;
my @bitaddr_labels;
my %bitaddr_opcodes;

$bitaddr_opcodes{$_} = 1 for words(<<BITADDR_OPCODES);
	82	# ANL C, bit addr
	B0	# ANL C, /bit addr
	C2	# CLR bit addr
	B2	# CPL bit addr
	20	# JB bit addr, reladdr
	10	# JBC bit addr, reladdr
	30	# JNB bit addr, realaddr
	A2	# MOV C, bit addr
	92	# MOV bit addr, C
	72	# ORL C, bit addr
	A0	# ORL C, /bit addr
	D2	# SETB
BITADDR_OPCODES
	

open(my $f, '<', $mcu_registers_txt) or die "Can't open $mcu_registers_txt: $!";
while (<$f>) {
	next unless /^[0-9A-Fa-f]+[Hh]/;
	chomp;
	my @cols = split ' ';	
	my $addr = $cols[0];
	$addr =~ s/[Hh]$//; # remove 'H' suffix
    $addr =~ s/^0+(?=[1-9]|0[A-F])//; # remove unnecessary leading zeroes
	$labels{$addr} = $cols[1];
	unless (hex($addr) & 0x07) {
		for my $i (0..7) {
			$bitaddr_labels[hex($addr) + $i] = $cols[11 - $i];
		}
	}
}

while (<>) {
	# first lesson: ignore DB values, ew
	# second lesson: \b doesn't block us from matching on things like #0A5h
	# third lesson: original disassembler doesn't use a different format for byte addresses vs bit addresses
	if (!/;/ && !/\bDB\b/ && /(?<!#)\b([0-9A-Fa-f]+[Hh])\b/)
	{
		my ($ins_addr, $ins_bytes) = split ' ';
		my $rawaddr = $1;
		my $addr = substr($1, 0, -1);
		my $label;
		my $opcode = substr($ins_bytes, 0, 2);
		if (exists $bitaddr_opcodes{$opcode}) {
			$rawaddr = "bit.$rawaddr";
			$label = $bitaddr_labels[hex $addr];
		} else {
			$label = $labels{$addr};
		}
		
		if (defined $label) {
			my $padlen = 40 - length($_);
			my $pad = ' ' x $padlen;
			s/$/$pad ; $rawaddr = $label/m;
			#print;
		}		
	}
	print;
}

sub words
{
    my @lines = split /\n/, shift;
    s/#.*$// for @lines;
    map { split ' ', $_ } @lines;
}