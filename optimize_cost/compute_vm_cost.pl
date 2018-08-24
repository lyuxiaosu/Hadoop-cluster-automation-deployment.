#! /usr/bin/perl

use File::Basename;

open (fw, "> vm_cost.txt") or die "Open vm_cost.txt fail, $!";
open (fcode, "> code.R") or die "Open code.R fail, $!";
open (fr_vm_config, "< hardware_configure2.txt") or die "Open hardware_configure.txt fail, $!";
open (fr_job_time, "< collected_log_data.txt") or die "Open collected_log_data.txt fail, $!";
open (fr_jobs, "< applications.txt") or die "Open applications.txt fail, $!";

readline fr_vm_config;
readline fr_job_time;

%cpu_unit_price = ();
%vm_price = ();

#generate job map, key is the name of the job, value is the number index, e.g. jobs[wordcount] = 1
%jobs = ();
$index = 1;
while($line = <fr_jobs>) {
	chomp($line);
	$jobs{$line} = $index;
	$index++;
}



$cpu_unit_price{0.2} = 20;
$cpu_unit_price{0.4} = 40;
$cpu_unit_price{0.6} = 60;
$cpu_unit_price{0.8} = 80;
$cpu_unit_price{1} = 100;

$memory_unit_price = 2;

$disk_speed_price = 0.1;

#generate vm price map, key is the name of the vm configration, value is the price, e.g. vm_price[C3] = 456
$index = 1;
%vms = ();
while($line=<fr_vm_config>) {
	my @config = split(" ", $line);
	my $cpu = $config[1];
	my $mem = $config[2];
	my $disk = $config[3];
	my $cluster = $config[0];

	my $price = $cpu_unit_price{$cpu} + $mem * $memory_unit_price + $disk * $disk_speed_price;
	if ($cpu == 1 && $mem >= 9 && $disk == 100) {
		$price = 1.5 * $price;
	}
	my $C_name = "C".$index;
	#print fw "$cluster $price\n"; 
	$vm_price{$C_name} = $price;
	$vms{$cluster} = $index;
	$index++;
	printf("$C_name:$price\n");
}

#generate job execution time map on particular vm, key is the time name, value is the time, e.g. job_times_on_vm[T3.3] = 146.54
%job_times_on_vm = ();
while($line = <fr_job_time>) {
	my @array = split(" ", $line);
	my $job = $array[0];
	chomp($job);
	my $vm = $array[1];
	chomp($vm);
	my $Time_name = "T".$jobs{$job}.".".$vms{$vm};
	my $time = $array[11]/1000;
	$job_times_on_vm{$Time_name} = $time;
	print("$Time_name is $time\n");
}

$vm_types = `cat hardware_configure.txt|wc -l` -1;
$job_nums = `cat applications.txt|wc -l`;

$unknowns = $vm_types * $job_nums;

#generate the coefficent matrix for the object function, and write this matrix to code.R 
$content = <<EOF;
library(lpSolveAPI)
GetOptimalSolution <- function() {
	lprec <- make.lp(0, $unknowns)
	lp.control(lprec, sense="min")
EOF
print fcode $content;
print("object--------------------\n");
my $one_line;
for ($i = 1; $i <= $vm_types; $i++) {
	for ($j = 1; $j <= $job_nums; $j++) {
		my $Time_name = "T".$j.".".$i;
		my $C_name = "C".$i;
		my $multiply = $vm_price{$C_name} * $job_times_on_vm{$Time_name};
		my $multiply_name = $C_name."*".$Time_name;
		print fw "$vm_price{$C_name} $job_times_on_vm{$Time_name} $multiply_name $multiply\n";	
		#print("$multiply,");
		$one_line = $one_line.$multiply.",";
	}
}
chop($one_line);
printf($one_line);
$content = <<EOF;
	set.objfn(lprec,c($one_line))
EOF
print fcode $content;
print("\n");

$vm_limit = 10;
#generate constraint coefficent matrix and write it to code.R
print("(1)--------------------------------\n");
for ($i = 1; $i <= $vm_types; $i++) {
	my @constraint_coefficent = ();
	for ($j = 0; $j < $unknowns ; $j++) {
		$constraint_coefficent[$j] = 0;
	}
	printf("constraint $i is:");
	my $valid_index = $i * 3;
	for ($j = $valid_index - 3; $j < $valid_index; $j++) {
		$constraint_coefficent[$j] = 1;
	}
	my $one_line;
	for ($j = 0; $j < $unknowns; $j++) {
		$one_line = $one_line.$constraint_coefficent[$j].",";
#printf("$constraint_coefficent[$j],");
	}
	chop($one_line);
	printf($one_line);
	$content = <<EOF;
	add.constraint(lprec, c($one_line), "<=", $vm_limit)
EOF
	print fcode $content;
	printf("\n");
}

#generate constraint coefficent matrix and write it to code.R
print("(3)----------------\n");
%job_number = ();
$job_number{1} = 5;
$job_number{2} = 4;
$job_number{3} = 7;

for ($i = 0; $i < $job_nums; $i++) {
	my @constraint_coefficent = ();
        for ($j = 0; $j < $unknowns ; $j++) {
                $constraint_coefficent[$j] = 0;
        }
        printf("constraint $i is:");

	for ($j = $i; $j < $unknowns; $j = $j + 3) {
		$constraint_coefficent[$j] = 1;
	}
	my $one_line;
	for ($j = 0; $j < $unknowns; $j++) {
		$one_line = $one_line.$constraint_coefficent[$j].",";
#printf("$constraint_coefficent[$j],");
        }
	chop($one_line);
	printf($one_line);
	my $job_num = $job_number{$i + 1};
	$content = <<EOF;
	add.constraint(lprec, c($one_line), "=", $job_num)
EOF
	print fcode $content;
        printf("\n");
}

#generate constraint coefficent matrix and write it to code.R
print("(2)-----------------------\n");
$deadline = 120;
for ($i = 1; $i <= $vm_types; $i++) {
        my @constraint_coefficent = ();
        for ($j = 0; $j < $unknowns ; $j++) {
                $constraint_coefficent[$j] = 0;
        }
        printf("constraint $i is:");
        my $valid_index = $i * 3;
	my $job_index = 0;
        for ($j = $valid_index - 3; $j < $valid_index; $j++) {
		$job_index++;
		my $Time_name = "T".$job_index.".".$i;
#printf("$Time_name j=$j\n");
		my $diff_time = $job_times_on_vm{$Time_name} - $deadline;
		$constraint_coefficent[$j] = $diff_time;
        }
	my $one_line;
        for ($j = 0; $j < $unknowns; $j++) {
		$one_line = $one_line.$constraint_coefficent[$j].",";
#printf("$constraint_coefficent[$j],");
        }
	chop($one_line);
	printf($one_line);
	$content = <<EOF;
	add.constraint(lprec, c($one_line), "<=", 0)
EOF
	print fcode $content;
        printf("\n");
}

$content = <<EOF;
	solve(lprec)
	get.objective(lprec)
	get.variables(lprec)
}
EOF

print fcode $content;

close fr_hardware;
close fw;
close fr_job_time;
close fr_jobs;
close fcode;

print("variables---------------------\n");
for ($i = 1; $i <= $vm_types; $i++) {
	for($j = 1; $j <= $job_nums; $j++) {
		my $var_name = "X".$j.".".$i;
		printf("$var_name ");
	}
	printf("\n");
}
