 #!/usr/local/bin/perl
 use File::Basename;
 use Getopt::Long;
 use Excel::Writer::XLSX;
 use POSIX;
 #use IO::Tee; 
 use Cwd;
 my $dir=@ARGV[0];
  ##Parameter
 my $opt_loop = 1;
 my $opt_parse = 1;
 my $opt_run_pctool = 1;
 my $mode = "spsb";
 my $help = 0;
 my $wr_xls = 0;
 GetOptions(
 	'loop_opt|l=s' => \$opt_loop,
 	'parse_opt|p=s' => \$opt_parse,
 	'opt_run_pctool|r=s' => \$opt_run_pctool,
 	'mode|m=s' => \$mode,
 	'wr_xls|w=s' => \$wr_xls,
 	'help|h!' => \$help,
 );
 my $cmdline;
 my $run_test_log;
 my $pc_tool_log;
 my $p1_str_start = "devad=01, memad=0004";
 my $p1_str_end = "devad=01, memad=0002";
 my $back;
 my $p2_str_start = "devad=01, memad=00d4";
 my $p2_str_end = "devad=01, memad=0014";
 my $back_2;
 
 my $print_log = 0;
 my $pass = 0;
 my $pass_2 = 0;
 my $path_name;
 my $year_month_day=strftime("%Y%m%d",localtime());
 my $row_num = 0;
 my $temp;
 my $data;
 if($help){
 	print "perl run.pl [-h][-l 0/1][-p 0/1][-r 0/1] DIR_PATH \n";
 	print "-h: print help info\n";
 	print "-l: default is 1. Set to 0 will disable loop the DIR_PATH function and the script will not update dir_list.txt\n";
 	print "-p: default is 1. Set to 0 will disable parse the ipf function and use the existing parse result\n";
 	print "-r: default is 1. Set to 0 will disalbe run pc_tool function.\n";
 	print "-m: default is spsb. Valid options have dpdb & dpsb\n";
 	exit;
 }
 if($wr_xls){
	 ###Excel Set
	 print "Write result to Excel File : ".$mode."_".$year_month_day.".xlsx\n";
	 my $sig_workbook = Excel::Writer::XLSX->new($mode."_".$year_month_day.".xlsx") or die "Fail to open Excel File";
	 $sig_worksheet = $sig_workbook->add_worksheet();

	 #设置表头字体格式
	 my $format_head = $sig_workbook->add_format(
	    num_format   	=> '@',                    ##为了避免字符串中数字使用原格式，使用@设置数字的默认格式同文字格式
	    font      		=> '黑体',    			   ##设置字体格式为黑体
	    bold      		=> 1,                         ##加粗
	    align     		=> 'center',                  ##居中
	    border       	=> 1                       ##边界框线
	 );
	#设置字体格式
	 my $format_1 = $sig_workbook->add_format(
	    num_format   => '@',                     
	    size         => 10,
	    font         => '宋体',
	    border       => 1,
	    align        => 'center',
	 );
	 my $format_red = $sig_workbook->add_format(
	    num_format   => '@',                     
	    size         => 10,
	    font         => '宋体',
	    color 		 => 'red',
	    border       => 1,
	    align        => 'center',
	 );
	 $sig_worksheet->set_column('A:A', 60);
	 $sig_worksheet->set_column('B:B', 30);
	 $sig_worksheet->set_column('C:C', 30);
	 $sig_worksheet->set_column('D:D', 30);
	 #写表头
	 $sig_worksheet->write($row_num,0,"CASE_PATH",$format_head);
	 $sig_worksheet->write($row_num,1,"RESULT",$format_head);
	 $sig_worksheet->write($row_num,2,"NPU Status Register",$format_head);
	 $sig_worksheet->write($row_num,3,"NPU Status Register 2",$format_head);
	 $row_num++;
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
 	
 	if( $opt_run_pctool == 1){ ##Run PC_Tool and Check the Result
 		$pc_tool_log = $dir_list."\\pc_tool_log.txt";
	 	$cmdline="python pc_tool.py -d "."$dir_list"." > $pc_tool_log";
	 	print "C. run: ".$cmdline."\n";
	 	system($cmdline);
	 	print "D. check pc_tool_log.txt\n";
	 	open(fp_pc_tool_log,$pc_tool_log);
	 	$print_log = 0;
	 	$pass = 0;
	 	$pass_2 = 0;
	 	
	 	while($line = <fp_pc_tool_log>){
	 		$back=index($line,$p1_str_start);
	 		$back_2 = index($line,$p2_str_start);
	 		if($back != -1){
	 			#print "   Result is: ".$line;
	 			print "D-1. check port 1 status\n";
	 			$print_log = 1;
	 			$temp = $line;
	 			$temp = (split(",",$temp,4))[3];
	 			$temp =~ s/[\n\r]//g;
	 			if($wr_xls){
	 				$sig_worksheet->write($row_num,2,$temp,$format_1);
	 			}
	 			if($line =~ /..7a/){##FIXME, Only for SPSB
	 				$pass = 1;
	 			}
	 		}
	 		if($back_2 != -1){
	 			print "D-2. check port 2 status\n";
	 			$print_log = 1;
	 			if($line =~ /..7a/){##For dual port
	 				$pass_2 = 1;
	 			}
	 			$temp = $line;
	 			$temp = (split(",",$temp,4))[3];
	 			if($wr_xls){
	 				$sig_worksheet->write($row_num,3,$temp,$format_1);
	 			}
	 		}
	 		if($print_log == 1){
	 			$back=index($line,$p1_str_end);
	 			$back_2=index($line,$p2_str_end);
		 		if($back != -1 || $back_2 != -1){
		 			$print_log = 0;
		 		}##Stop print debug_info
		 		else{
		 			print "   Result is: ".$line;
		 		}
	 		}
	 	}
	 	close(fp_pc_tool_log);
	 	if($wr_xls){
	 		$sig_worksheet->write($row_num,0,$dir_list,$format_1);
	 	}
		#$sig_worksheet->write($row_num,1,"PASS",$format_1);
	 	#if($pass and ($mode ~= /spsb/ or ($mode ~= /spsb/ and $pass_2))){
	 	if($mode eq /spsb/){
		 	if($pass){
		 		print "Case Pass at ".$dir_list."\n";
		 		if($wr_xls){
		 			$sig_worksheet->write($row_num,1,"PASS",$format_1);
		 		}
		 	}
		 	else{
		 		print "Case Fail at ".$dir_list."\n";
		 		if($wr_xls){
		 			$sig_worksheet->write($row_num,1,"Fail",$format_red);
		 		}
		 		print "E-1. Print Port 1 Debug data\n";
 				$data = &join_str($pc_tool_log,"e000","e01f");
 				print "E-1.(1) first error RX_Data is :\n";
 				print "\t".$data."\n";
 				$data = &join_str($pc_tool_log,"e080","e09f");
 				print "E-1.(2) first error Golden_Data is :\n";
 				print "\t".$data."\n";
 				$data = &join_str($pc_tool_log,"e020","e03f");
 				print "E-1.(3) match_cnt RX_Data is :\n";
 				print "\t".$data."\n";
 				$data = &join_str($pc_tool_log,"e0a0","e0bf");
 				print "E-1.(4) match_cnt Golden_Data is :\n";
 				print "\t".$data."\n";
 				$data = &join_str($pc_tool_log,"e040","e05f");
 				print "E-1.(5) last RX_Data is :\n";
 				print "\t".$data."\n";
 				$data = &join_str($pc_tool_log,"e0c0","e0df");
 				print "E-1.(6) last Golden_Data is :\n";
 				print "\t".$data."\n";
		 	}
	 	}
	 	else{
	 		if($pass && $pass_2){
	 			print "Case Pass at ".$dir_list."\n";
	 			if($wr_xls){
		 			$sig_worksheet->write($row_num,1,"PASS",$format_1);
		 		}
	 		}
	 		else{
	 			print "Case Fail at ".$dir_list."\n";
	 			if($wr_xls){
		 			$sig_worksheet->write($row_num,1,"Fail",$format_red);
		 		}
		 		
	 			if($pass == 0){##Port 1 has Failed
	 				print "E-1. Print Port 1 Debug data\n";
	 				$data = &join_str($pc_tool_log,"e000","e01f");
	 				print "E-1.(1) first error RX_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e080","e09f");
	 				print "E-1.(2) first error Golden_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e020","e03f");
	 				print "E-1.(3) match_cnt RX_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e0a0","e0bf");
	 				print "E-1.(4) match_cnt Golden_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e040","e05f");
	 				print "E-1.(5) last RX_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e0c0","e0df");
	 				print "E-1.(6) last Golden_Data is :\n";
	 				print "\t".$data."\n";
	 			}
	 			if($pass_2 == 0){##Port 2 has Failed
	 				print "E-2. Print Port 2 Debug data\n";
	 				$data = &join_str($pc_tool_log,"e100","e11f");
	 				print "E-2.(1) first error RX_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e180","e19f");
	 				print "E-2.(2) first error Golden_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e120","e13f");
	 				print "E-2.(3) match_cnt RX_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e1a0","e1bf");
	 				print "E-2.(4) match_cnt Golden_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e140","e15f");
	 				print "E-2.(5) last RX_Data is :\n";
	 				print "\t".$data."\n";
	 				$data = &join_str($pc_tool_log,"e1c0","e1df");
	 				print "E-2.(6) last Golden_Data is :\n";
	 				print "\t".$data."\n";
	 			}
	 		}
	 	}
	 	$row_num++;
	 	#close(fp_pc_tool_log);
	}
 	else{
 		print " Skip B. run pc_tool\n";
 		print " Skip C. Check Result\n"; 
 	}
 	
 }
 if($wr_xls){
 	$sig_workbook->close();
 }
 

 sub join_str{
 	my $s1,$s2;
 	my $process=0;
 	my $temp="";
 	my $res="";
 	my $fp;
 	my($file_name,$start,$end)=@_;
 	#print "Involve join_str sub-function\n";
 	#print "File name is $file_name\n";
 	#print "start str is $start\n";
 	#print "end str is $end\n";
 	open(fp,$file_name) or die "Fail to open file\n";
 	while($line = <fp>){
 		#print "line string is :".$line."\n";
 		$s1 = index($line,$start);
 		$s2 = index($line,$end);
 		if($s1 != -1){
 			$process = 1;
 		}
 		if($s2 != -1){
 			$process = 0;
 		}
 		if($process){
 			$temp = substr($line,-5,4);
 			$res = join("",$temp,$res);
 			#print "temp is :".$temp."\n";
 			#print "res is :".$res."\n";
 		}
 	}
 	close(fp);
 	return $res;
 }

 