#!/usr/local/bin/perl
 #system "rm -rf";
 use File::Basename;
 use Cwd;
 use Getopt::Long;

 my $help = 0;
 GetOptions(
  'help|h!' => \$help,
 );
 if($help){
  print "Involve test.pl & proc_512_ipf.pl to parse IPF file and generate data file\n";
  print "perl run_test.pl DIR [mode] [loop]\n";
  print "For example, run SPSB: 
              perl run_test.pl DIR\n";
  print "For example, loop all the sub_dirs and run DPDB : 
              perl run_test.pl DIR dpdb loop\n";
  print "mode: 
              dpdb, test_mode is dual_port_dual_bank;
              dpsb, test_mode is dual_port_single_bank;
              loop, test_mode is single_port and loop_mode is true;
              otherwise, test_mode is single_port\n";
  print "loop:
              loop, loop_mode is true;
              otherwise, loop_mode is false;\n";
  exit;
 }print "----------------Enter run_test.pl----------------\n";
 printf "Wrapper of Parse script version 1.0\n";
 $my_pwd = getcwd;
 my $os = $^O;
 my $cp;
 my $dir_split;
 if($os eq "linux"){
  print "Current System is Linux;\n";
  $cp = "copy";
  $dir_split = "/";
 }
 elsif($os eq "MSWin32"){
  print "Current System is Windows;\n";
  $cp = "copy /Y";
  $dir_split = "\\";
 }
 else{
  print "Current System is Unknow: ".$os." ;\n";
  exit;
 }
 $work_dir = $ARGV[0];
 $dual = $ARGV[1];
 $loop = $ARGV[2];
 $cnt = 1;
 if($dual =~ /dpdb/){
 	$dual = "dual_port_dual_bank";
 }
 elsif($dual =~ /dpsb/){
 	$dual = "dual_port_single_bank";
 }
 else {
 	$dual = "single_port";
 }
 if($loop eq "loop" || $dual eq "loop"){
 	$loop = "loop";
 }
 else {
 	$loop = "no_loop";
 }
 print "Work Dir is: ",$work_dir,"\n";
 print "Dual Port Config is: ",$dual,"\n";
 print "Loop Config is:",$loop,"\n";

 if($loop eq "loop"){
  print "This is Loop Handle Process"."\n";
 	opendir DIR, ${work_dir} or die "Can not open \"$work_dir\"\n";
	@filelist = readdir DIR;

	foreach $file (@filelist) {
		if(!($file =~ /\./) and !($file =~ /\.\./)){
			#print("current dir is: ",getcwd."\n");
   			#print "In Loop Dir Parse IPF File in ".getcwd."/".$work_dir."/".$file."\n";
   			print "**********Parse ".$cnt." IPF Case**********************************\n";
   			&wrapper_test(getcwd."/".$work_dir."/".$file,$dual);
   			&generate_test_ini(getcwd."/".$work_dir."/".$file,$dual);
   			#print("In Loop Dir: current dir is ",getcwd);
   			#print "******************************************************************\n";
 			print "**********Parse ".$cnt." IPF Case Success**************************\n";
 			#print "******************************************************************\n";
 			$cnt = $cnt + 1;
   		}
   		else {
   			print "******************************************************************\n";
   			print "Invalid ".$file." Skip\n";
   			print "******************************************************************\n";
   		}
	}

	closedir DIR;
 }
 else {
  print "This is No_loop Handle Process"."\n";
  print "**********Parse ".$cnt." IPF Case**********************************\n";
  &wrapper_test(getcwd."/".$work_dir,$dual);
  &generate_test_ini(getcwd."/".$work_dir,$dual);
  print "**********Parse ".$cnt." IPF Case Success**************************\n";
 }



 sub wrapper_test{
 	if($#_ != 1) {
 		print "Parametr Number is not 1, it is: ",$#_,"\n";
 		exit(-1);
 	}
 	my $dir = @_[0];
 	my $mode = @_[1];
 	my $cur =  getcwd;
 	my $cmdline = "";
 	#my $result_name = "parse_result.txt";
 	#open (parse_result, "> $result_name") or die "open parse_result.txt failed";
 	chdir $dir;
 	#print "******************************************************************\n";
 	print "Parse IPF File in ".$dir."\n";
 	#print("In wrapper_test, current dir is: ",getcwd."\n");
 	#print "******************************************************************\n";
  $txt_out = getcwd()."\\txt_out";
  print "txt_out path is: ".$txt_out."\n";
  if(-d $txt_out){
    if($os eq "Linux")
    {
      my $cmdline= "rm -rf ".$txt_out;
    }
    else {
      my $cmdline= "rd /s /q ".$txt_out;
    } 
    system($cmdline); 
    print "Delete txt_out dir\n";
  }
  mkdir $txt_out;
 	if(($mode =~ /dual_port_dual_bank/) or ($mode =~ /dual_port_single_bank/)){#Need to FIX!!!!!!!!!!!!!!!!
 		print "Involve test.pl in ".$mode."\n";
 		$cmdline = "perl ".$cur."/test.pl ./ilk_in.ipf ./ilk_out.ipf";
 		system($cmdline);
 		$cmdline = "perl ".$cur."/test.pl ./ilk_in2.ipf ./ilk_out2.ipf _2";
 		system($cmdline);
 		#system("perl test.pl ".$dir_split."ilk_in.ipf ".$dir_split."ilk_out.ipf _2 >>$parse_result");
 		print "Involve copy operation in ".$mode."\n";

 		$cmdline = $cp." txt_out".$dir_split."sim_data_ilk_in.txt 	txt_out".$dir_split."data_ilk_in.txt";
    print "Copy cmd is : ".$cmdline."\n";
 		system($cmdline);
 		$cmdline = $cp." txt_out".$dir_split."sim_cmd_ilk_in.txt 	txt_out".$dir_split."cmd_ilk_in.txt";
 		system($cmdline);
 		$cmdline = $cp." txt_out".$dir_split."sim_data_ilk_in_2.txt 	txt_out".$dir_split."data_ilk_in_2.txt";
 		system($cmdline);
 		$cmdline = $cp." txt_out".$dir_split."sim_cmd_ilk_in_2.txt 	txt_out".$dir_split."cmd_ilk_in_2.txt";
 		system($cmdline);
 		$cmdline = $cp." txt_out".$dir_split."npu_tx_linecount.txt 	txt_out".$dir_split."tx_linecount.txt";
 		system($cmdline);
 		$cmdline = $cp." txt_out".$dir_split."sim_sop_eop_in.txt 	txt_out".$dir_split."sop_eop_in.txt";
 		system($cmdline);
 		$cmdline = $cp." txt_out".$dir_split."npu_tx_linecount_2.txt txt_out".$dir_split."tx_linecount_2.txt";
 		system($cmdline);
 		$cmdline = $cp." txt_out".$dir_split."sim_sop_eop_in_2.txt 	txt_out".$dir_split."sop_eop_in_2.txt";
 		system($cmdline);
 		
		print "Involve proc_512_ipf.pl in ".$mode."\n";
		$cmdline = "perl ".$cur."/proc_512_ipf.pl ./";
		system($cmdline);
		$cmdline = "perl ".$cur."/proc_512_ipf.pl ./ _2";
		system($cmdline);
 		#system("perl proc_512_ipf.pl / >>parse_result")		 		or die "Fail in involve proc_512_ipf.pl";
 		#system("perl proc_512_ipf.pl / _2 >>parse_result")			or die "Fail in involve proc_512_ipf.pl";
 	}
 	else{
 		print "Involve test.pl in ".$mode."\n";
 		$cmdline = "perl ".$cur."/test.pl ./ilk_in.ipf ./ilk_out.ipf";
 		system($cmdline);
 		print "Involve proc_512_ipf.pl in ".$mode."\n";
 		$cmdline = "perl ".$cur."/proc_512_ipf.pl ./";
 		system($cmdline);
 	}
 	#close(parse_result);
 	chdir $cur;
 }

 sub generate_test_ini{
 	if($#_ != 1) {
 		print "Parametr Number is not 1, it is: ",$#_,"\n";
 		exit(-1);
 	}
 	my $dir = @_[0];
 	my $mode = @_[1];
 	print "Involve generate_test_ini, current dir is: ",$dir."\n";
 	my $filename=$dir."/test.ini";
 	open (test_ini,">$filename") or die "couldnot open the file: \"$filename\" \n";
 	open (new_cfg,$dir."/txt_out/new_cfg.ini") or die "couldnot open the file: \"$dir\/txt_out\/new_cfg.ini\" \n";
 	#open (new_cfg_2,$dir."/txt_out/new_cfg_2.txt");
  #Soft Reset
  printf test_ini "w 1f.1.1f ffff\n";##set soft_reset_cnt to 1 ms
  printf test_ini "w 1f.1.0a 0001\n";##trigger soft_reset 
  printf test_ini "delay 4000\n";###wait 4 ms
  printf test_ini "r 1f.1.0a\n";
  #Power Up
 	printf test_ini "source powerup.ini\n";
 	if($mode =~ /dual_port_dual_bank/)
 	{
 		print "Generate ".$filename." for Mode DPDB\n";
 		open (new_cfg_2,$dir."/txt_out/new_cfg_2.ini") or die "couldnot open the file: \"$dir\/txt_out\/new_cfg_2.ini\" \n";
 		printf test_ini "source align_dpdb.ini\n";
 		while(<new_cfg>){
 			print test_ini $_;
 		}
 		while(<new_cfg_2>){
 			print test_ini $_;
 		}
 		printf test_ini "testtx\n".
                  		"testrx\n".
                  		"testtx2\n".
                  		"testrx2\n";
        printf test_ini "w 1f.1.1 0003\n";
        close(new_cfg_2);
 	}
 	elsif($mode =~ /dual_port_single_bank/){
 		print "Generate ".$filename." for Mode DPSB\n";
 		printf test_ini "source align_dpsb.ini\n";
 		print "Now Do not Support DPSB\n";
 		exit(-1);
 	}
 	else
 	{
 		print "Generate ".$filename." for Mode SPSB\n";
 		printf test_ini "source align_spsb.ini\n";
 		#printf test_ini "@arr1";
 		#print  test_ini "\n".<new_cfg>."\n";
 		while(<new_cfg>){
 			print test_ini $_;
 		}
 		printf test_ini "testtx\n".
                  		"testrx\n";
        printf test_ini "w 1f.1.1 0001\n";
 	}
    printf test_ini "delay 2000\n";
    printf test_ini "r 1f.2.5f0\n".
                  	"r 1f.2.5e6\n".
                  	"r 1e.2.5f0\n".
                  	"r 1e.2.5e6\n";
    if($mode =~ /dual_port_dual_bank/ or $mode =~/dual_port_single_bank/){
      print test_ini "r 1f.12.5f0\n".
                     "r 1e.2.15f0\n".
                     "r 1f.12.5e6\n".
                     "r 1e.2.15e6\n";
    }
    print test_ini  "r 1f.1.4\n".
                    "r 1f.1.D4\n".
                    "r 1f.1.6\n".
                    "r 1f.1.26\n".
                    "r 1f.1.7\n".
                    "r 1f.1.27\n".
                    "r 1f.1.8\n".
                    "r 1f.1.28\n".
                    "r 1f.1.9\n".
                    "r 1f.1.29\n".
                    "r 1f.1.02\n".
                    "r 1f.1.22\n".
                    "r 1f.1.03\n".
                    "r 1f.1.23\n".
                    "r 1f.1.14\n".
                    "r 1f.1.34\n".
                    "r 1f.1.15\n".
                    "r 1f.1.35\n".
                    "r 1f.1.40\n".
                    "r 1f.1.41\n".
                    "r 1f.1.42\n".
                    "r 1f.1.43\n".
                    "r 1f.1.44\n".
                    "r 1f.1.45\n".
                    "r 1f.1.46\n".
                    "r 1f.1.47\n".
                    "r 1f.1.48\n".
                    "r 1f.1.49\n".
                    "r 1f.1.4a\n".
                    "r 1f.1.4b\n".
                    "r 1f.1.4c\n".
                    "r 1f.1.4d\n".
                    "r 1f.1.4e\n".
                    "r 1f.1.4f\n".
                    "r 1f.1.50\n".
                    "r 1f.1.51\n".
                    "r 1f.1.52\n".
                    "r 1f.1.53\n".
                    "r 1f.1.54\n".
                    "r 1f.1.55\n".
                    "r 1f.1.56\n".
                    "r 1f.1.57\n".
                    "r 1f.1.58\n".
                    "r 1f.1.59\n".
                    "r 1f.1.5a\n".
                    "r 1f.1.5b\n".
                    "r 1f.1.5c\n".
                    "r 1f.1.5d\n";
    close(test_ini);
    close(new_cfg);
 }
