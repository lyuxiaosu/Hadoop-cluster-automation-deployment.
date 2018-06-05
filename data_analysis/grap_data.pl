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
	$path = $_[0];
	$am_container = "_000001";
	if ($path =~ $am_container) {
		print ("this is am container, do not analyze it\n");
		return ();
	}

	$file = $path."/syslog";
	print("log file is $file\n");
	#get read bytes
	$line = `grep "FILE: Number of bytes read" $file`;
	@array = split("=", $line);
	if (!@array) {
		return ();
	}
	$read_bytes = $array[1];

	#get write bytes
	$line = `grep "FILE: Number of bytes written" $file`;
	@array = split("=", $line);
	if (!@array) {
		return ();
	}

	$write_bytes = $array[1];
	print("$write_bytes\n");

	#get map input records
	$line = `grep "Map input records" $file`;
	@array = split("=", $line);
	if (!@array) {
		return ();
        }
	$map_input_records = $array[1];

	#get map output records 
	$line = `grep "Map output records" $file`;
	@array = split("=", $line);
        if (!@array) {
                return ();
        }
        $map_output_records = $array[1];
	
	#get cpu time spent
	$line = `grep "CPU time spent (ms)" $file`;
	@array = split("=", $line);
        if (!@array) {
                return ();
        }
	$cpu_time_spent = $array[1];

	print("read:$read_bytes, write:$write_bytes, input_records:$map_input_records, output_records:$map_output_records, cpu_time:$cpu_time_spent\n");
	print ("max_index: $max_index\n");
	return ($read_bytes, $write_bytes, $map_input_records, $map_output_records, $cpu_time_spent);
}

sub grap_data {
	@data = (0, 0, 0, 0, 0, 0);
	$untar_folder_name = $_[0];
	@folder = `find $untar_folder_name -type d`;
	$len = @folder;
	if ($len >= 2) {
		$application_id = $folder[1];
		chomp($application_id);
		print("application id = $application_id\n");
		@folders = `find $application_id -type d`;
		$len = @folders;
		$container_count = $len - 1;
		print ("container count is $container_count @folders\n");
		$valid_container_count = 0;
		for (my $i = 1; $i <= $container_count; $i++) {
			$container = $folders[$i];
			chomp($container);
			@array = do_grap_data($container);
			if (@array) {
				$valid_container_count++;
				$data[0] = $data[0] + $array[0];
				$data[1] = $data[1] + $array[1];
				$data[2] = $data[2] + $array[2];
				$data[3] = $data[3] + $array[3];
				$data[4] = $data[4] + $array[4];
			}
			#print ("container path is:$container\n");
		}
		#get the average values
		if ($valid_container_count != 0) {
			$data[0] = int($data[0]/$valid_container_count);
			$data[1] = int($data[1]/$valid_container_count);
			$data[2] = int($data[2]/$valid_container_count);
			$data[3] = int($data[3]/$valid_container_count);
			$data[4] = int($data[4]/$valid_container_count);
			$data[5] = $container_count;
			return @data;
		} else {
			return ();
		}
	}
	return ();
}

open (fr, "< applications.txt") or die "Open applications.txt fail, $!";
open (fw, "> collected_log_data.txt") or die "Open collected_log_data.txt fail, $!";
print fw "application\tcluster_slave\tcontainer_count\tread_bytes\twrite_bytes\tinput_records\toutput_records\tcpu_time_spent\n";

$log_folder = "/home/lyuxiaosu/data_analysis/logs/";
my %hash_data = ();
my $max_index = 100000000;
while ($line=<fr>) {
	print ($line);
	my $application = $line;
	chomp($application);
	for (my $i = 1; $i < $max_index; $i++) {
		for (my $j = 1; $j < $max_index; $j++) {
			my $tar_file = $log_folder."cluster".$i."_slave".$j."_".$application.".tar.gz";
			my $cluster_slave = "cluster".$i."_slave".$j;
			if (-e $tar_file) {
				print ("$tar_file\n");
				my $untar_folder_name = $log_folder.$cluster_slave."_".$application;
				untar($tar_file, $untar_folder_name);
				@array = grap_data($untar_folder_name);
				`rm -rf $untar_folder_name`;
				if (@array) {
					print fw "$application\t$cluster_slave\t$array[5]\t$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\n";
				}
			} else {
				last;	
			}
		}
		my $file = $log_folder."cluster".($i+1)."_slave1_".$application.".tar.gz";
		if (-e $file) {
			next;
		} else {
			last;
		}
	}
}

close fr;
close fw;
