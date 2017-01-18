 #!/usr/local/bin/perl
 use File::Basename;
 use Cwd;
 my $dir=@ARGV[0];
 my $cmdline;
 my $run_test_log;
 my $pc_tool_log;
 my $result_str = "memad=0004";
 my $print_log = 0;
 ####Step 1: Loop Recursivly the dir and generate the dir_list.txt which record the valid dir paths"####
 print "****************"."Step 1: Loop the work dir: ".$dir."****************"."\n";
 $cmdline="perl recursive_loop.pl ".$dir;
 system($cmdline);
 print "Check the dir_list.txt for the valid dir paths\n";
 ####Step 2: Read the dir_list.txt and parse ipf files"
 $dir_list_name = "dir_list.txt";
 $cnt=0;
 open(f_dir_list, "<",$dir_list_name) or die "can't open file '$dir_list_name' for read. $!";
 while($dir_list=<f_dir_list>){
 	chomp($dir_list);
 	$cnt = $cnt + 1;
 	#print $cnt.". Dir is: ".$dir_list."\n";
 	print "****************"."Step 2: Handle ".$cnt."th IPF Case at $dir_list"."****************"."\n";
 	#print "Chomp dir_list is ".$dir_list."\n";
 	$run_test_log = $dir_list."\\run_test_log.txt";
 	$cmdline="perl run_test.pl ".$dir_list." >".$run_test_log;
 	print "A. run: ".$cmdline."\n";
 	system($cmdline);
 	#print "Step 3: Involv PC_TOOL to run ".$cnt."th case at $dir_list"."\n";
 	$pc_tool_log = $dir_list."\\pc_tool_log.txt";
 	$cmdline="python pc_tool.py -d "."$dir_list"." > $pc_tool_log";
 	print "B. run: ".$cmdline."\n";
 	system($cmdline);
 	print "C. check pc_tool_log.txt\n";
 	open(fp_pc_tool_log,$pc_tool_log);
 	$print_log = 0;
 	while($line = <fp_pc_tool_log>){
 		$back=index($line,$result_str);
 		if($back != -1 || $print_log == 1){
 			print "   Result is: ".$line;
 			$print_log = 1;
 		}
 	}
 	close(fp_pc_tool_log);
 }
 ####Step 3: Involve PC_TOOL
 #print ""

 