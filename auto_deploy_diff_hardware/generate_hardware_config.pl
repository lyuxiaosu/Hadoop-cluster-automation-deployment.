#! /usr/bin/perl

@cpu_share = (1/5, 2/5, 3/5, 4/5, 1);
@memory = (1, 2, 4, 6, 8, 7, 9);
@disk_read_speed = (10, 20, 40, 50, 70, 80, 90, 100);

open(f, "> hardware_configure.txt") or die "Open hardware_configure.txt fail, $!";
open(f2, "> hardware_configure2.txt") or die "Open hardware_configure2.txt fail, $!";

print f "cluster_name cpu_frequency memory disk_read_speed disk_write_speed\n";
print f2 "cluster_name cpu_share memory disk_read_speed disk_write_speed\n";

$r = `lscpu |grep MHz`;
@array = split(/\s+/, $r);

$cluster_index = 1;
foreach $cs (@cpu_share) {
	foreach $m (@memory) {
		foreach $drs (@disk_read_speed) {
			my $cluster_name = "cluster".$cluster_index;
			my $cpu_freqency = ($array[2] * $cs);
			print f "$cluster_name $cpu_freqency $m $drs $drs\n";				
			print f2 "$cluster_name $cs $m $drs $drs\n";				
			$cluster_index++;
		}
	}
}

close f;
close f2;
