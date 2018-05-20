#! /usr/bin/perl

@cpu_core = (1, 2, 3, 4);
@cpu_share = (1/5, 2/5, 3/5, 4/5, 1);
@memory = (1, 2, 4, 8, 16, 32);
@disk_read_speed = (10, 20, 40, 60, 80, 100); 

open(f, "> hardware_configure.txt") or die "Open hardware_configure.txt fail, $!";
open(f2, "> hardware_configure2.txt") or die "Open hardware_configure2.txt fail, $!";

print f "cpu_core\tcpu_frequency\tmemory\tdisk_read_speed\tdisk_write_speed\n";

$r = `lscpu |grep MHz`;
@array = split(/\s+/, $r);

foreach $cc (@cpu_core) {
	foreach $cs (@cpu_share) {
		foreach $m (@memory) {
			foreach $drs (@disk_read_speed) {
				local $cpu_freqency = $array[2] * $cs;
				print f "$cc\t$cpu_freqency\t$m\t$drs\t$drs\n";				
				print f2 "$cc\t$cs\t$m\t$drs\t$drs\n";				
			}
		}
	}
}
 
close f;
close f2;
