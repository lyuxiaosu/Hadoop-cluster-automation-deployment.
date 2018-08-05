#! /usr/bin/perl

use List::Util qw[min max];
use File::Basename;

sub check_parameter {
	if (@ARGV != 1) {
		$cmd_name = basename($0);
		print ("usage: $cmd_name docker_image\n");
		exit;
	}
}
check_parameter();

sub get_cpu_frequency {
	$cpu_share = $_[0];
	$cpu_core = $_[1];
	$r = `lscpu |grep MHz`;
	@array = split(/\s+/, $r);
	$cpu_freqency = ($array[2] * $cpu_share)/$cpu_core;
	if ($cpu_share == -1) {
		$cpu_freqency = $array[2];
	}
	return $cpu_freqency;
}

sub get_cpu_period_quota {
	my $cpu_share = $_[0];
        my @cpu_period_quota;
        if ($cpu_share == 0.2) {
                @cpu_period_quota=(50000, 10000);
        }
        elsif ($cpu_share == 0.4) {
                @cpu_period_quota=(50000, 20000);
        }
        elsif ($cpu_share == 0.6) {
                @cpu_period_quota=(50000, 30000);
        }
        elsif ($cpu_share == 0.8) {
                @cpu_period_quota=(50000, 40000);
        }
        elsif ($cpu_share == 1) {
                @cpu_period_quota=(50000, 50000);
        }
        elsif ($cpu_share == -1) {
                @cpu_period_quota=(-1, -1);
        }
        else {
                @cpu_period_quota=(-1, -1);
                print ("invalid cpu_share, no match\n");
        }
	return @cpu_period_quota;
}

sub create_slaves {
	my $cluster_name = $_[0];
	my $count = $_[1];
	my $memory = $_[2];
	my $cpu_period = $_[3];
	my $cpu_quota = $_[4];
	my $disk_speed = $_[5];
	print("cluster:$cluster_name memory:$memory cpu_period:$cpu_period cpu_quota:$cpu_quota disk_speed:$disk_speed\n");
	for ($i = 0; $i < $count; $i++) {
		my $container_index = $i + 1;
		$output = `/home/lyuxiaosu/add_node_from_master.sh $image_name $container_index $container_index $i $cpu_period $cpu_quota $memory $disk_speed 1 $block_size`;
		print("$output\n");
	}
}

sub destroy_cluster {
	$slave_count = $_[0];
	$output = `/home/lyuxiaosu/stop_node_with_weave.sh master-slave 1 $slave_count`;
}

$image_name=$ARGV[0];

$block_size=64;
$range_beg = 30;
$range_end = 256;

open (f, "< hardware_configure2.txt") or die "Open hardware_configure2.txt fail, $!";
#open (f, "< hardware_configure_test.txt") or die "Open hardware_configure3.txt fail, $!";
open (fw, "> progress.txt") or die "Open progress.txt fail, $!";
print fw "cluster_name\n";

readline f; #skip the frist line

$index = 2;
#stop cluster first
destroy_cluster(10);

while ($line=<f>) {
	@array = split(" ", $line);
	$cluster_name = $array[0];
	$cpu_share = $array[1];
	$memory = $array[2];
	$disk_speed = $array[3];
	@cpu_period_quota = get_cpu_period_quota($cpu_share);
	#create master
	print("create cluster $cluster_name, start master...\n");
	$block_size = `./generate_random.sh $range_beg $range_end`;
	$output = `/home/lyuxiaosu/start_master_with_weave.sh $image_name $memory 1 $block_size`;
	`sleep 15`;
	#create slaves
	print("create and start slaves...\n");
	create_slaves($cluster_name, 3, $memory, $cpu_period_quota[0], $cpu_period_quota[1], $disk_speed);
	#prepare data and folder on master
	print("prepare master...\n");
	my $workload_size = $block_size * 6;
	$output = `/home/lyuxiaosu/auto_deploy_diff_hardware/prepare_master.sh $workload_size`;
	print "$output\n";
	#run applications 
	$output = `/home/lyuxiaosu/auto_deploy_diff_hardware/run_applications.sh $cluster_name 3`;
	print("all applications have been executed on $cluster_name, result=$output\n");
	#after running, destroy the cluster and reset the resource
	print("reset cluster resource...\n");
	print("destroy $cluster_name ...\n");
	destroy_cluster(3);
	$index++;
	print fw "$cluster_name\n";
}

close f;
close fw;
