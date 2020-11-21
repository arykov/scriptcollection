#!/usr/bin/perl

my $currentLine;
my $text;
my @threaddumps;
my $threaddumpindex=0;
my $orderbyfrequency=0;

my $i=0;
my $paramArraySize=@ARGV;
my $lines=9999;

#read first command line parameter
while($i < $paramArraySize){
	my $param = $ARGV[$i];

	if($param eq "-h"){
		print("Program is ment to help with thread dump extracts from the log.\n");
		print("Usage: OrderThreadDump.pl [-f] [-n lines]\n");
		print("\t-f to order by frequency.\n");
		print("\t-n number of lines in the stack to take in consideration.\n");
		print("By default orders by alphabet from the top of the stack.\n");
		print("Data is read from the STDIN and written to STDOUT.\n");
		print("Number printed before each stack trace is the frequency of this exact stack.\n");
		exit(0);
	}
	if($param eq "-f"){
		$orderbyfrequency = 1;		
		print("Ordering by frequency.\n\n");
	
	}
	if($param eq "-n"){
		$i = $i + 1;
		$lines = 0 + $ARGV[$i];		
		if($lines <= 0){
			print("Number of lines should be positive.");
			exit(1)
		}
		print("Number of lines in the stacktrace: ");
		print($lines);
		print("\n\n");
	
	}
	$i = $i + 1;	
}

#read stdin while EOF is not reached
while(defined($currentLine=<STDIN>)){

	#regular expression for beginning of the thread. Anything in quotes followed somewhere by tid=
	if($currentLine =~ /"*".* tid=*.*/){		
		
		my $line = 0;
		my $threaddump = "";
		#stack has to start with several white spaces or tab			
		while(defined($currentLine=<STDIN>) && (($currentLine =~ /^   *.*$/) || ($currentLine =~ /^		*.*$/) )){			
			#concatentate strings depending on how we will order this 
			if($line < $lines ){
				$threaddump =$threaddump.$currentLine;
			}
			$line = $line + 1
		}
		
		#add another stack to the array
		$threaddumps[$threaddumpindex] = $threaddump;
		$threaddumpindex++;
	}	
}


#sort stacks(or reverse stacks) by alphabet
@threaddumps = sort(@threaddumps);


my $previousthreaddump = "";
my $counter = 0;
my @freqthreaddumps;
$threaddumpindex = 0;


#calculate frequencies and eliminate duplicates
foreach my $threaddump (@threaddumps){
	if($threaddump eq $previousthreaddump){
		$counter ++;
	}else{
		if($counter > 0){
			if($orderreverse == 1){
				#should reverse stack back to normal
				$previousthreaddump = join('', reverse(split(/^/, $previousthreaddump, 100)));
			}
			
			#add frequency at the beginning
			$freqthreaddumps[$threaddumpindex] = $counter."  ***"."\n".$previousthreaddump;
			$threaddumpindex++;
		}
 		$counter = 1;		
		$previousthreaddump = $threaddump;
	}
	
}


#for the last threaddump
if($orderreverse == 1){
			#should reverse stack back to normal
			$previousthreaddump = join('', reverse(split(/^/, $previousthreaddump, 100)));
}
#add frequency at the beginning
$freqthreaddumps[$threaddumpindex] = $counter."  ***"."\n".$previousthreaddump;

#order stacks by frequency if required
if($orderbyfrequency == 1){
	@freqthreaddumps=sort {$b <=> $a} @freqthreaddumps;
}

#print stacks out
foreach my $threaddump (@freqthreaddumps){
	print($threaddump);
	print("\n");
}
