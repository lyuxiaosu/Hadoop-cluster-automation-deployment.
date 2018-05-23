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
	if ($cpu_share == -1) {
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
			if ($cpucore_used{$j} + $each_cpu_core_share <= 0.8 && !($j ~~ @cpusets)) {
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

sub reset_resource {
	$current_memory = 0;
	%cpucore_used=(0, 0, 1, 0, 2, 0, 3, 0);
}

$image_name=$ARGV[0];

open (f, "< hardware_configure2.txt") or die "Open hardware_configure2.txt fail, $!";
readline f; #skip the frist line

print("$count[0]\t$count[1]\n");
$index = 2;
$container_index = 1;
while ($line=<f>) {
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
		#the cluster has been finished, run applications one by one
		`sleep 5`;
		#after running, destroy the cluster and reset the resource
		reset_resource();
		$container_index = 1;
		# TODO: stop all slaves
		#`sleep 600`
		exit;
	} else {
		print("container=$container_index,line_index=$index:cpusets= @cpusets cpu_core:$cpu_core \
				cpu_share:$cpu_share memory:$memory cpu_period:$cpu_period_quota[0] cpu_quota:$cpu_period_quota[1]\n");
		$str_cpusets = join(',', @cpusets);
		print ("str_cpusets:$str_cpusets\n");
		#create a new container
		`/home/lyuxiaosu/add_node_from_master.sh $image_name $container_index $container_index $str_cpusets $cpu_period_quota[0] $cpu_period_quota[1] $memory $disk_speed`;
		$index++;
		$container_index++;
	}

}

close f;
