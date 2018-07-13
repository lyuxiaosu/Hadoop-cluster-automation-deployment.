#! /usr/bin/perl

use File::Basename;

open (fw, "> compare_real_predict.csv") or die "Open compare_real_predict.txt fail, $!";
open (fr_real, "< predict.txt") or die "Open predict.txt fail, $!";
open (fr_predict, "< time_prediction.txt") or die "Open time_prediction.txt fail, $!";
open (fr_cluster, "< collected_log_data.txt") or die "Open collected_log_data.txt fail, $!";

readline fr_real;
readline fr_cluster;

print fw "real_time(ms),predict_time(ms),application,cpu_frequency,memory(G),disk_speed(Mb/s),cluster,loss_percent\n";

our @predict_time = ();
our %cluster = (); # key is the real time, value is (application, cluster)

sub create_predict_time_array {
 	while(my $line=<fr_predict>) {
		my $time = $line;
		chomp($time);
		push(@predict_time, $time);	
	}
	my $len = @predict_time;
	print("@predict_time\n");
}

sub create_cluster_hashTable {
	while (my $line=<fr_cluster>) {
		my @array = split(" ", $line);
		my $app = $array[0];
		my $cluster = $array[1];
		my $cpu_time = $array[11];
		my @value = ($app, $cluster);
		$cluster{$cpu_time} = \@value;
	}
}

create_predict_time_array();
create_cluster_hashTable();

our $index = 0;
while(my $line=<fr_real>) {
	my @array = split(" ", $line);
	my $real_time = $array[213];
	my $predict_time = $predict_time[$index];
	my $application = $cluster{$real_time}[0];
	my $cpu_frequency = $array[0];
	my $memory = $array[1];
	my $disk_speed = $array[2];
	my $cluster_i = $cluster{$real_time}[1];
	my $loss_percent = ($real_time - $predict_time) / $real_time;

	print fw "$real_time,$predict_time,$application,$cpu_frequency,$memory,$disk_speed,$cluster_i,$loss_percent\n";
	$index++;
}

close fw;
close fr_real;
close fr_predict;
