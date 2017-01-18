 #!/usr/local/bin/perl
 use File::Basename;
 use Cwd;
 my $dir=@ARGV[0];
 my $cmdline;
 my $result_name;
 my $pc_tool_log;
 #my $fp_res;
 ####Step 1: Loop Recursivly the dir and generate the dir_list.txt which record the valid dir paths"####
 print "Step 1: Loop the work dir: ".$dir."\n";
 $cmdline="perl recursive_loop.pl ".$dir;
 system($cmdline);
 ####Step 2: Read the dir_list.txt and parse ipf files"
 $dir_list_name = "dir_list.txt";
 $cnt=0;
 open(f_dir_list, "<",$dir_list_name) or die "can't open file '$dir_list_name' for read. $!";
 while($dir_list=<f_dir_list>){
 	$cnt = $cnt + 1;
 	#print $cnt.". Dir is: ".$dir_list."\n";
 	print "Step 2: Parse ".$cnt."th IPF Recursivly at $dir_list"."\n";
 	$result_name = $dir_list."/run_test_log.txt";
 	#open(fp_res,"<",$result_name); 
 	$cmdline="perl run_test.pl ".$dir_list." >>".$result_name;
 	system($cmdline);
 	print "Step 3: Involv PC_TOOL to run ".$cnt."th case at $dir_list"."\n";
 	$pc_tool_log = $dir_list."/pc_tool_log.txt";
 	$cmdline="python pc_tool.py "."$dir_list"." >> $pc_tool_log";
 	system($cmdline);
 }
 ####Step 3: Involve PC_TOOL
 #print ""

 