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

$max_memory = 30;
$current_memory = 0;
$max_cpu_core = 4;
%cpucore_used=(0, 0, 1, 0, 2, 0, 3, 0);
sub get_cpusets {
	$cpu_core = $_[0];
	$cpu_share = $_[1];
	$memory = $_[2];
	if ($cpu_share == -1) {# -1 means container will not share cpu core with other container. It will occupy 80% of cpu
		$each_cpu_core_share = 1;
	} else {
		$each_cpu_core_share = $cpu_share/$cpu_core;
	}
	$i = 0;
	@cpusets = ();
	$current_memory = $current_memory + $memory;
	if ($current_memory > $max_memory) {
		print("exceed the max memory, return empty cpusets\n");
		return @cpusets;
	}

	while ($i < $cpu_core) {# cpu_core is the needed cpu number
		$j = 0;
		for (; $j < $max_cpu_core; $j++) {
			if ($cpucore_used{$j} + $each_cpu_core_share <= 1 && !($j ~~ @cpusets)) {
				$cpucore_used{$j} = $cpucore_used{$j} + $each_cpu_core_share; 
				push(@cpusets, $j);
				last;
			}
		}
		if ($j == $max_cpu_core) {
			last;
		} else {
			$i = $i + 1;
		}
	} 
	$array_len = @cpusets;
	if ($array_len != $cpu_core) {
		@cpusets = ();
	}
	return @cpusets;
}

sub get_minimum_cpu_memory {
	$minimum_memory = 1000;
	$minimum_cpu = 1000;

	$len = @one_cluster_conf;
	for ($i = 0; $i < $len; $i++) {
		if ($minimum_memory > $one_cluster_conf[$i][4]) {
			$minimum_memory = $one_cluster_conf[$i][4];
		} 	
		if ($minimum_cpu > $one_cluster_conf[$i][0]) {
			$minimum_cpu = $one_cluster_conf[$i][0];
		}
#print("EEEEEOOOOO$one_cluster_conf[$i][0] $one_cluster_conf[$i][1] $one_cluster_conf[$i][2] $one_cluster_conf[$i][3] $one_cluster_conf[$i][4] $one_cluster_conf[$i][5]\n");
	}
	return ($minimum_memory, $minimum_cpu);
}

sub printArray {
	$len = @one_cluster_conf;
	for ($i = 0; $i < $len; $i++) {
		print("OOOOO$one_cluster_conf[$i][0] $one_cluster_conf[$i][1] $one_cluster_conf[$i][2] $one_cluster_conf[$i][3] $one_cluster_conf[$i][4] $one_cluster_conf[$i][5]\n");
	}
}
sub create_slaves {
	$len = @one_cluster_conf;
	for ($i = 0; $i < $len; $i++) {
		my $container_index = $i + 1;
		$output = `/home/lyuxiaosu/add_node_from_master.sh $image_name $container_index $container_index $one_cluster_conf[$i][1] $one_cluster_conf[$i][2] $one_cluster_conf[$i][3] $one_cluster_conf[$i][4] $one_cluster_conf[$i][5] $one_cluster_conf[$i][0]`;
#print("!!!!!!!create slave $container_index $one_cluster_conf[$i][0] $one_cluster_conf[$i][1] $one_cluster_conf[$i][2] $one_cluster_conf[$i][3] $one_cluster_conf[$i][4] $one_cluster_conf[$i][5]\n");
		print("$output\n");
	}
}
sub reset_resource {
	$current_memory = 0;
	%cpucore_used=(0, 0, 1, 0, 2, 0, 3, 0);
}

sub destroy_cluster {
	$slave_count = $_[0];
	$output = `/home/lyuxiaosu/stop_node_with_weave.sh master-slave 1 $slave_count`;
}

$image_name=$ARGV[0];

open (f, "< hardware_configure2.txt") or die "Open hardware_configure2.txt fail, $!";
#open (f, "< hardware_configure_test.txt") or die "Open hardware_configure3.txt fail, $!";
#open (f, "< hw_cf.txt") or die "Open hardware_configure3.txt fail, $!";

readline f; #skip the frist line
open (fw, "> cluster_hardware_configure.txt") or die "Open cluster_hardware_configure.txt fail, $!";
print fw "name\tcpu_core\tcpu_frequency\tmemory\tdisk_read_speed\tdisk_write_speed\n";

print("$count[0]\t$count[1]\n");
$index = 2;
$container_index = 1;
$cluster_index = 1;
#stop cluster first
destroy_cluster(10);

@one_cluster_conf = ();
$single_nodes = 0;
while ($line=<f>) {
	$offset = length($line);
	@array = split("\t", $line);
	$cpu_core = $array[0];
	$cpu_share = $array[1];
	$memory = $array[2];
	$disk_speed = $array[3];
	@cpu_period_quota = get_cpu_period_quota($cpu_share);
	@cpusets = get_cpusets($cpu_core, $cpu_share, $memory);
	$array_len = @cpusets;
	if ($array_len == 0) {
		print("reach the maximum containers allocation, line_index=$index, cpu_core:$cpu_core cpu_share:$cpu_share memory:$memory\n");
		my $len = @one_cluster_conf;
		if ($len == 1) {
			print("-----single node: cpu_core=$one_cluster_conf[0][0], str_cpusets=$one_cluster_conf[0][1], cpu_period_quota=$one_cluster_conf[0][2], cpu_period_quota=$one_cluster_conf[0][3], memory=$one_cluster_conf[0][4], disk_speed=$one_cluster_conf[0][5]\n");
			@one_cluster_conf = ();
			reset_resource();
			$container_index = 1;
			$single_nodes++;
			next;
		}
		#get the minimum cpu cores and memory from the cluster
		($minimum_memory, $minimum_cpu_core) = get_minimum_cpu_memory();
		#create master
		print("create and start master...\n");
		$output = `/home/lyuxiaosu/start_master_with_weave.sh $image_name $minimum_memory $minimum_cpu_core`;
		`sleep 10`;
		$container_index--;
		#create slaves
		print("create and start slaves...\n");
		create_slaves();
		exit;
		`sleep 40`;
		#prepare data and folder on master
		$output = `/home/lyuxiaosu/auto_deploy_diff_hardware/prepare_master.sh`;
		#run applications 
		#the cluster has been finished, run applications one by one
		$cluster_name="cluster".$cluster_index;
		print("++++++ cluster:$cluster_name, the minimum memory:$minimum_memory, cpu_core:$minimum_cpu_core\n");
		#$output = `/home/lyuxiaosu/auto_deploy_diff_hardware/run_applications.sh $cluster_name $container_index`;
		print("all applications have been executed on $cluster_name, result=$output\n");
		#after running, destroy the cluster and reset the resource
		print("reset cluster resource...\n");
		reset_resource();
		@one_cluster_conf = ();
		print("destroy $cluster_name ...\n");
		destroy_cluster($container_index);
		$container_index = 1;
		$cluster_index++;
		seek(f, -$offset, 1); #go to the previous line
	} else {
		print("container:$container_index,line_index:$index cpusets:@cpusets cpu_core:$cpu_core cpu_share:$cpu_share memory:$memory cpu_period:$cpu_period_quota[0] cpu_quota:$cpu_period_quota[1] disk_speed:$disk_speed\n");
		$str_cpusets = join(',', @cpusets);
		#print ("str_cpusets:$str_cpusets\n");
		my @conf = ($cpu_core, $str_cpusets, $cpu_period_quota[0], $cpu_period_quota[1], $memory, $disk_speed);
		push(@one_cluster_conf, \@conf);
		print("after push\n");
		$cluster = "cluster".$cluster_index;
		$slave = "slave".$container_index;
		$combine_name = join('_', $cluster, $slave);
		$cpu_frequency = get_cpu_frequency($cpu_share, $cpu_core);
		print fw "$combine_name\t$cpu_core\t$cpu_frequency\t$memory\t$disk_speed\t$disk_speed\n";
		$index++;
		$container_index++;
	}

}

print("single node is:$single_nodes\n");
close f;
close fw;
