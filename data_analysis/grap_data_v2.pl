#! /usr/bin/perl

use File::Basename;

sub untar {
	$tar_file = $_[0];
	$untar_folder_name = $_[1];
	$output = `mkdir -p $untar_folder_name`;
	print ("untar $tar_file to $untar_folder_name\n");
	$output = `tar -xzvf $tar_file -C $untar_folder_name`;
}

sub do_grap_data {
	my $path = $_[0];
	my $am_container = "_000001";
	if ($path =~ $am_container) {
		print ("this is am container, do not analyze it\n");
		return ();
	}

	my $file = $path."/syslog";
	print("log file is $file\n");
	#get read bytes
	my $line = `grep "FILE: Number of bytes read" $file`;
	my @array = split("=", $line);
	if (!@array) {
		return ();
	}

	my $read_bytes = $array[1];

	#get write bytes
	$line = `grep "FILE: Number of bytes written" $file`;
	@array = split("=", $line);
	if (!@array) {
		return ();
	}

	my $write_bytes = $array[1];
	#print("$write_bytes\n");

	#get map input records
	$line = `grep "Map input records" $file`;
	@array = split("=", $line);
	if (!@array) {
		return ();
        }
	my $map_input_records = $array[1];

	#get map output records 
	$line = `grep "Map output records" $file`;
	@array = split("=", $line);
        if (!@array) {
                return ();
        }
        my $map_output_records = $array[1];
	
	#get cpu time spent
	$line = `grep "CPU time spent (ms)" $file`;
	@array = split("=", $line);
        if (!@array) {
                return ();
        }
	my $cpu_time_spent = $array[1];

	#get map materialized bytes
	$line = `grep "Map output materialized bytes" $file`;
	@array = split("=", $line);
	if (!@array) {
		return ();
	}

	my $map_materialized_bytes = $array[1];

	#get input split bytes
	$line = `grep "Input split bytes" $file`;
	@array = split("=", $line);
	if (!@array) {
		return ();
	}

	my $input_split_bytes = $array[1];

	#get Combine input records
	$line = `grep "Combine input records" $file`;
	@array = split("=", $line);
	if (!@array) {
		return();
	}

	my $combine_input_records = $array[1];

	# get combine output records
	my $combine_output_records = $combine_input_records;
	if ($combine_input_records != 0) {
		$line = `grep "Combine output records" $file`;	
		@array = split("=", $line);
		$combine_output_records = $array[1];
	} 

	#get spilled records
	$line = `grep "Spilled Records" $file`;
	@array = split("=", $line);
	if (!@array) {
		return();
	}
	
	my $spilled_records = $array[1];

	print("read:$read_bytes, write:$write_bytes, input_records:$map_input_records, output_records:$map_output_records, cpu_time:$cpu_time_spent\n");
	return ($read_bytes, $write_bytes, $map_input_records, $map_output_records, $cpu_time_spent, $map_materialized_bytes, $input_split_bytes, $combine_input_records, $combine_output_records, $spilled_records);
}

sub grap_data {
	my @data = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	my $untar_folder_name = $_[0];
	print ("untar folder name is $untar_folder_name\n");
	my $application_folder = `ls $untar_folder_name`;
	$application_folder = $untar_folder_name."/".$application_folder;
	chomp($application_folder);
	print("application folder is $application_folder\n");
	my @folder = `ls $application_folder`;
	my $len = @folder;
	my $valid_container_count = 0;
	for (my $i = 0; $i < $len; $i++) {
		my $container = $application_folder."/".$folder[$i];
		chomp($container);
		print("container folder is $container\n");
		my @array = do_grap_data($container);
		if (@array) {
			$valid_container_count++;
			$data[0] = $data[0] + $array[0];
			$data[1] = $data[1] + $array[1];
			$data[2] = $data[2] + $array[2];
			$data[3] = $data[3] + $array[3];
			$data[4] = $data[4] + $array[4];
			$data[5] = $data[5] + $array[5];
			$data[6] = $data[6] + $array[6];
			$data[7] = $data[7] + $array[7];
			$data[8] = $data[8] + $array[8];
			$data[9] = $data[9] + $array[9];
		}

	}
	if ($valid_container_count != 0) {
		$data[0] = int($data[0]/$valid_container_count);
		$data[1] = int($data[1]/$valid_container_count);
		$data[2] = int($data[2]/$valid_container_count);
		$data[3] = int($data[3]/$valid_container_count);
		$data[4] = int($data[4]/$valid_container_count);
		$data[5] = int($data[5]/$valid_container_count);
		$data[6] = int($data[6]/$valid_container_count);
		$data[7] = int($data[7]/$valid_container_count);
		$data[8] = int($data[8]/$valid_container_count);
		$data[9] = int($data[9]/$valid_container_count);
		print("valid container count is $valid_container_count, cpu_time is $data[4]\n");
		return @data;
	} else {
		return ();
	}
}

open (fr, "< applications.txt") or die "Open applications.txt fail, $!";
open (fw, "> collected_log_data.txt") or die "Open collected_log_data.txt fail, $!";
print fw "application cluster_slave read_bytes write_bytes input_records output_records bytes_read_from_hdfs map_materialized_bytes input_split_bytes combine_input_records combine_output_records spilled_records cpu_time_spent\n";

$log_folder = "/home/lyuxiaosu/data_analysis/logs/";
our %hash_data = ();
our $max_index = 120;
while ($line=<fr>) {
	print ($line);
	my $application = $line;
	chomp($application);
	for (my $i = 1; $i <= $max_index; $i++) {
		my $cluster = "cluster".$i;
		my $untar_folder_name = $log_folder.$cluster."_".$application;
		for (my $j = 1; $j <= 3; $j++) {
			my $tar_file = $log_folder.$cluster."_slave".$j."_".$application.".tar.gz";
			if (-e $tar_file) {
				print ("$tar_file\n");
				untar($tar_file, $untar_folder_name);
			} else {
				last;	
			}
		}
		my @array = grap_data($untar_folder_name);
		if (@array) {
			print fw "$application $cluster $array[0] $array[1] $array[2] $array[3] $array[5] $array[6] $array[7] $array[8] $array[9] $array[4]\n";
		}
		`rm -rf $untar_folder_name`;
	}
}

close fr;
close fw;