#!/usr/local/bin/perl
 #system "rm -rf";
 use File::Basename;
 use Cwd;
 printf "Wrapper of Parse script version 1.0\n";
 $my_pwd = getcwd;
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
 	my $result_name = "parse_result.txt";
 	#open (parse_result, "> $result_name") or die "open parse_result.txt failed";
 	chdir $dir;
 	#print "******************************************************************\n";
 	print "Parse IPF File in ".$dir."\n";
 	#print("In wrapper_test, current dir is: ",getcwd."\n");
 	#print "******************************************************************\n";

 	if(($mode =~ /dual_port_dual_bank/) or ($mode =~ /dual_port_single_bank/)){#Need to FIX!!!!!!!!!!!!!!!!
 		print "Involve test.pl in ".$mode."\n";
 		$cmdline = "perl ".$cur."/test.pl ./ilk_in.ipf ./ilk_out.ipf >".$result_name;
 		system($cmdline);
 		$cmdline = "perl ".$cur."/test.pl ./ilk_in2.ipf ./ilk_out2.ipf _2 >".$result_name;
 		system($cmdline);
 		#system("perl test.pl /ilk_in.ipf /ilk_out.ipf _2 >>$parse_result");
 		print "Involve copy operation in ".$mode."\n";
 		$cmdline = "copy txt_out/sim_data_ilk_in.txt 	txt_out/txt_out/data_ilk_in.txt 	>>".$result_name;
 		system($cmdline);
 		$cmdline = "copy txt_out/sim_cmd_ilk_in.txt 	txt_out/txt_out/data_cmd_in.txt 	>>".$result_name;
 		system($cmdline);
 		$cmdline = "copy txt_out/sim_data_ilk_in_2.txt 	txt_out/txt_out/data_ilk_in_2.txt 	>>".$result_name;
 		system($cmdline);
 		$cmdline = "copy txt_out/sim_cmd_ilk_in_2.txt 	txt_out/txt_out/data_cmd_in_2.txt 	>>".$result_name;
 		system($cmdline);
 		$cmdline = "copy txt_out/npu_tx_linecount.txt 	txt_out/txt_out/tx_linecount.txt 	>>".$result_name;
 		system($cmdline);
 		$cmdline = "copy txt_out/sim_sop_eop_in.txt 	txt_out/txt_out/sop_eop_in.txt 		>>".$result_name;
 		system($cmdline);
 		$cmdline = "copy txt_out/npu_tx_linecount_2.txt txt_out/txt_out/tx_linecount_2.txt 	>>".$result_name;
 		system($cmdline);
 		$cmdline = "copy txt_out/sim_sop_eop_in_2.txt 	txt_out/txt_out/sop_eop_in_2.txt 	>>".$result_name;
 		system($cmdline);
 		#system("copy txt_out/sim_data_ilk_in.txt 	txt_out/txt_out/data_ilk_in.txt 	>>$parse_result") 	or die "Fail in involve copy";
 		#system("copy txt_out/sim_cmd_ilk_in.txt    	txt_out/txt_out/data_cmd_in.txt 	>>$parse_result") 	or die "Fail in involve copy";
 		#system("copy txt_out/sim_data_ilk_in_2.txt 	txt_out/txt_out/data_ilk_in_2.txt 	>>$parse_result")	or die "Fail in involve copy";
 		#system("copy txt_out/sim_cmd_ilk_in_2.txt 	txt_out/txt_out/data_cmd_in_2.txt 	>>$parse_result")	or die "Fail in involve copy";
 		#system("copy txt_out/npu_tx_linecount.txt 	txt_out/tx_linecount.txt  			>>$parse_result")	or die "Fail in involve copy";
 		#system("copy txt_out/sim_sop_eop_in.txt 	txt_out/sop_eop_in.txt 				>>$parse_result")	or die "Fail in involve copy";
		#system("copy txt_out/npu_tx_linecount_2.txt txt_out/tx_linecount_2.txt 			>>$parse_result") 	or die "Fail in involve copy";
		#system("copy txt_out/sim_sop_eop_in_2.txt 	txt_out/sop_eop_in_2.txt 			>>parse_result")	or die "Fail in involve copy";
		print "Involve proc_512_ipf.pl in".$mode."\n";
		$cmdline = "perl proc_512_ipf.pl / >>".$result_name;
		system($cmdline);
		$cmdline = "perl proc_512_ipf.pl / _2 >>".$result_name;
		system($cmdline);
 		#system("perl proc_512_ipf.pl / >>parse_result")		 		or die "Fail in involve proc_512_ipf.pl";
 		#system("perl proc_512_ipf.pl / _2 >>parse_result")			or die "Fail in involve proc_512_ipf.pl";
 	}
 	else{
 		print "Involve test.pl in ".$mode."\n";
 		$cmdline = "perl ".$cur."/test.pl ./ilk_in.ipf ./ilk_out.ipf >".$result_name;
 		system($cmdline);
 		print "Involve proc_512_ipf.pl in ".$mode."\n";
 		$cmdline = "perl ".$cur."/proc_512_ipf.pl ./ >>".$result_name;
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
  printf test_ini "w 1f.1.1f 0200\n";
  printf test_ini "w 1f.1.0a 0001\n"; 
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
                  		"testttx2\n".
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

    printf test_ini "r 1f.2.5f0\n".
                  	"r 1f.2.5e6\n".
                  	"r 1e.2.5f0\n".
                  	"r 1e.2.5e6\n".
                  	"r 1f.1.4\n";
    close(test_ini);
    close(new_cfg);
 }
