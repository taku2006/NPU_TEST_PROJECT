 #!/usr/local/bin/perl
 use File::Basename;
 use Cwd;
 my $dir=@ARGV[0];
 my $cmdline;
 ####Step 1: Loop Recursivly the dir and generate the dir_list.txt which record the valid dir paths"####
 print "Step 1: Loop the work dir: ".$dir."\n";
 $cmdline="perl recursive_loop.pl ".$dir;
 system($cmdline);
 ####Step 2: Read the dir_list.txt and parse ipf files"
 print "Step 2: Parse IPF Recursivly at $dir"."\n"; 
 $dir_list_name = "dir_list.txt";
 $cnt=0;
 open(f_dir_list, "<",$dir_list_name) or die "can't open file '$dir_list_name' for read. $!";
 while($dir_list=<f_dir_list>){
 	$cnt = $cnt + 1;
 	print $cnt.". Dir is: ".$dir_list."\n";
 	$cmdline="perl run_test.pl ".$dir_list;
 	system($cmdline);
 }

 