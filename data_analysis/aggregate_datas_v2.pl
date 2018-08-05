#! /usr/bin/perl

use File::Basename;

open (fw, "> sample_data.txt") or die "Open sample_data.txt fail, $!";
open (fr_log, "< collected_log_data.txt") or die "Open collected_log_data.txt fail, $!";

readline fr_log;

%clusterSlave_hardware = ();
%application_bytecode = ();

sub create_clusterSlave_hardware {
	%clusterSlave_hardware = $_[0];
	open (fr_hardware, "< hardware_configure.txt") or die "hardware_configure.txt fail, $!";
	readline fr_hardware;

 	while($line=<fr_hardware>) {
		$s = index($line, ' ');
		$cluster = substr($line, 0, $s);
		$log_data = substr($line, $s+1);
		chomp($log_data);
		$clusterSlave_hardware{$cluster} = $log_data;
	}	
	close fr_hardware;
}

sub create_application_bytecode {
	%application_bytecode = $_[0];
	open (fr_map, "< map.txt") or die "map.txt fail, $!";

        while($line=<fr_map>) {
                $s = index($line, ' ');
                $application = substr($line, 0, $s);
                $bytecode = substr($line, $s+1);
		chop($bytecode);
                $application_bytecode{$application} = $bytecode;
        }

	close fr_map;
}

sub split_file {
	$file = $_[0];
	open (fr, "< $file") or die "Open $file fail, $!";
	$ret = `wc -l $file`;
	@array = split(" ", $ret);
	$train = int($array[0]*0.9);
	print ("$train\n");
	open (fw_train, "> train.txt") or die "train.txt fail, $!";
	open (fw_test, "> test.txt") or die "test.txt fail, $!";
	open (fw_predict, "> predict.txt") or die "predict.txt fail, $!";
	for ($i = 0; $i < 214; $i++) {
		$str = "col".($i+1);
		print fw_train "$str ";
		print fw_test "$str ";
		print fw_predict "$str ";
	}
	print fw_train "\n";
	print fw_test "\n";
	print fw_predict "\n";
	
	$index = 1;
	while($line=<fr>) {
		if ($index <= $train) {
			print fw_train "$line";
		} else {
			if ($index < $array[0] - 100) {
				print fw_test "$line";
			} else {
				print fw_predict "$line";
			}
		}
		$index++;
	}
	close fw_train;
	close fw_test;
	close fw_predict;
}

create_clusterSlave_hardware(%clusterSlave_hardware);
create_application_bytecode(%application_bytecode);

while($line=<fr_log>) {
	$s = index($line, ' ');
	$application = substr($line, 0, $s);
	$rest = substr($line, $s+1);
	$s = index($rest, ' ');
	$cluster_slave = substr($rest, 0, $s);
	$log_data = substr($rest, $s+1);
#print ("application:$application, cluster_slave:$cluster_slave, log_data:$log_data");
	if (!$application_bytecode{$application}) {
		print("no has value with key:$application\n");
	}
	print fw "$clusterSlave_hardware{$cluster_slave} $application_bytecode{$application}$log_data";
}
close fr_log;

`python3 shuffle.py`;

split_file("shuffled_data.txt");
close fw; 
close fr_hardware;
