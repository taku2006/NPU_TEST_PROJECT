 #!/usr/local/bin/perl
 use File::Basename;
 use Getopt::Long;
 #use IO::Tee; 
 use Cwd;
 my $dir=@ARGV[0];
  ##Parameter
 my $opt_loop = 1;
 my $opt_parse = 1;
 my $opt_run_pctool = 1;
 my $help = 0;
 GetOptions(
 	'loop_opt|l=s' => \$opt_loop,
 	'parse_opt|p=s' => \$opt_parse,
 	'opt_run_pctool|r=s' => \$opt_run_pctool,
 	'help|h!' => \$help,
 );
 my $cmdline;
 my $run_test_log;
 my $pc_tool_log;
 my $result_str = "memad=0004";
 my $print_log = 0;
 my $pass = 0;
 if($help){
 	print "perl run.pl [-h][-l 0/1][-p 0/1][-r 0/1] DIR_PATH \n";
 	print "-h: print help info\n";
 	print "-l: default is 1. Set to 0 will disable loop the DIR_PATH function and the script will not update dir_list.txt\n";
 	print "-p: default is 1. Set to 0 will disable parse the ipf function and use the existing parse result\n";
 	print "-r: default is 1. Set to 0 will disalbe run pc_tool function.\n";
 	exit;
 }
 # if(-e run_result.txt){
 # 	open(fp_res,"<",run_result.txt);
 # 	close(fp_res);
 # }
 print $opt_loop."\n";
 ###Step 1: Loop Recursivly the dir and generate the dir_list.txt which record the valid dir paths"####
 if($opt_loop == 1){
 	#print "****************"."Step 1: Loop the work dir: ".$dir."****************"."\n";
 	$cmdline="perl recursive_loop.pl ".$dir;
 	system($cmdline);
 	print "Check the dir_list.txt for the valid dir paths\n";
 }	
 else{
 	print "****************Skip Loop Function, Use the existing dir_list.txt******"."\n";
 }
 
 ####Step 2: Read the dir_list.txt and parse ipf files"
 $dir_list_name = "dir_list.txt";
 $cnt=0;
 open(f_dir_list, "<",$dir_list_name) or die "can't open file '$dir_list_name' for read. $!";
 while($dir_list=<f_dir_list>){
 	chomp($dir_list);
 	$cnt = $cnt + 1;
 	print "****************"."Step 2: Handle ".$cnt."th IPF Case at $dir_list"."****************"."\n";
 	if( $opt_parse == 1){
 		$run_test_log = $dir_list."\\run_test_log.txt";
 		$cmdline="perl run_test.pl ".$dir_list." >".$run_test_log;
 		print "A. run: ".$cmdline."\n";
 		system($cmdline);
 	}
 	else{
 		print "Skip A. opt_parse"."\n";
 	}
 	if( $opt_run_pctool == 1){
 		$pc_tool_log = $dir_list."\\pc_tool_log.txt";
	 	#$cmdline="python pc_tool.py -d "."$dir_list"." > $pc_tool_log";
	 	#print "B. run: ".$cmdline."\n";
	 	#system($cmdline);
	 	print "C. check pc_tool_log.txt\n";
	 	open(fp_pc_tool_log,$pc_tool_log);
	 	$print_log = 0;
	 	$pass = 0;
	 	while($line = <fp_pc_tool_log>){
	 		$back=index($line,$result_str);
	 		if($back != -1){
	 			print "   Result is: ".$line;
	 			$print_log = 1;
	 			if($line =~ /..7a/){
	 				$pass = 1;
	 			}
	 		}
	 		if($print_log == 1){
	 			print "   Result is: ".$line;
	 		}
	 	}
	 	if($pass){
	 		print "Case Pass at ".$dir_list."\n";
	 	}
	 	else{
	 		print "Case Fail at ".$dir_list."\n";
	 	}
	 	close(fp_pc_tool_log);
 	}
 	else{
 		print " Skip B. run pc_tool\n";
 		print " Skip C. Check Result\n"; 
 	}
 	
 }
 

 