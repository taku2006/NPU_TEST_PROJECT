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
 my $mode = "spsb";
 my $help = 0;
 GetOptions(
 	'loop_opt|l=s' => \$opt_loop,
 	'parse_opt|p=s' => \$opt_parse,
 	'opt_run_pctool|r=s' => \$opt_run_pctool,
 	'mode|m=s' => \$mode,
 	'help|h!' => \$help,
 );
 my $cmdline;
 my $run_test_log;
 my $pc_tool_log;
 my $result_str = "devad=01, memad=0004";
 my $debug_str = "devad=01, memad=0002";
 my $print_log = 0;
 my $pass = 0;
 my $path_name;
 if($help){
 	print "perl run.pl [-h][-l 0/1][-p 0/1][-r 0/1] DIR_PATH \n";
 	print "-h: print help info\n";
 	print "-l: default is 1. Set to 0 will disable loop the DIR_PATH function and the script will not update dir_list.txt\n";
 	print "-p: default is 1. Set to 0 will disable parse the ipf function and use the existing parse result\n";
 	print "-r: default is 1. Set to 0 will disalbe run pc_tool function.\n";
 	print "-m: default is spsb. Valid options have dpdb & dpsb\n";
 	exit;
 }
 
 ###Step 1: Loop Recursivly the dir and generate the dir_list.txt which record the valid dir paths"####
 if($opt_loop == 1){
 	print "****************"."Step 1: Loop the work dir: ".$dir."****************"."\n";
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
 print "MODE is : ".$mode."\n";
 while($dir_list=<f_dir_list>){
 	chomp($dir_list);
 	$cnt = $cnt + 1;
 	print "****************"."Step 2: Handle ".$cnt."th IPF Case at $dir_list"."****************"."\n";
 	if( $opt_parse == 1){##Parse the ILK IPF File
 		$run_test_log = $dir_list."\\run_test_log.txt";
 		$cmdline="perl run_test.pl ".$dir_list." ".$mode." >".$run_test_log;
 		print "A. run: ".$cmdline."\n";
 		system($cmdline);
 	}
 	else{
 		print "Skip A. opt_parse"."\n";
 	}
 	##before run pc_tool, copy the txt_out dir since the top.ini will involve the dual_port_reg, ad_sel 
 	$path_name = getcwd;
 	$path_name =~ s/[\/]/\\/g;
 	$cmdline="xcopy ".$path_name."\\".$dir_list."\\txt_out ".$path_name."\\txt_out /Y /Q";
 	#print "Current work dir is ".$path_name."\n";
 	#print "cmdline is: ".$cmdline."\n";
 	print "B. copy the txt_out to pc_tool directory\n";
 	system($cmdline);

 	if( $opt_run_pctool == 1){##Run PC_Tool and Check the Result
 		$pc_tool_log = $dir_list."\\pc_tool_log.txt";
	 	$cmdline="python pc_tool.py -d "."$dir_list"." > $pc_tool_log";
	 	print "C. run: ".$cmdline."\n";
	 	system($cmdline);
	 	print "D. check pc_tool_log.txt\n";
	 	open(fp_pc_tool_log,$pc_tool_log);
	 	$print_log = 0;
	 	$pass = 0;
	 	while($line = <fp_pc_tool_log>){
	 		$back=index($line,$result_str);
	 		if($back != -1){
	 			#print "   Result is: ".$line;
	 			$print_log = 1;
	 			if($line =~ /..7a/){##FIXME, Only for SPSB
	 				$pass = 1;
	 			}
	 		}
	 		if($print_log == 1){
	 			$back=index($line,$debug_str);
		 		if($back != -1){
		 			$print_log = 0;
		 		}##Stop print debug_info
		 		else{
		 			print "   Result is: ".$line;
		 		}
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
 

 