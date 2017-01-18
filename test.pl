 #!/usr/local/bin/perl
 #system "rm -rf";
 use File::Basename;
 use Cwd;
 printf "Parse script version 1.0\n";
 $add_nops = 30;
 $add_nops_out = 30;
 $add_nops_in = 30;
 #system("rd /s /q ./txt_out");
 #mkdir "txt_out";
 #chdir "./txt_out";
 #my @arg = @ARGV;
 #print "my arg is: ",@arg[2],"\n";
 $my_pwd=getcwd;
 print "current work path is: ",$my_pwd,"\n";
 #print "Input ARGV[2] is: ",@ARGV[2],"\n";
 #print "Input ARGV[2] type 2 is: ",$ARGV[2],"\n";
 $dual_port = @ARGV[2];
 print "Dual Port parameter is: ",$dual_port,"\n";
 $filename = shift;
 print "input File: ",$filename,"\n";
 open (MYFILE, "$filename") or die "couldnot open the file: \"$filename\" \n";
 $workdir=dirname($filename);
 #print "workdir is :",$workdir,"\n";
 $txt_out = $workdir."\\txt_out";
 print "txt_out path is: ", $txt_out,"\n";
 my $cmdline= "rd /s /q ".$txt_out;
 system($cmdline);
 #$cmdline = "mkdir ".$txt_out;
 #system($cmdline) or die "Fail in ".$cmdline;
 mkdir $txt_out;
 #chdir "./txt_out";
 chdir $txt_out;
 

 @v_MYFILE = <MYFILE>;
 $data = "data_ilk_in".$dual_port.".txt";
 $cmd  = "temp_cmd.txt";
 $cmd_len  = "temp_cmd_len.txt";
 $spep = "temp_spep.txt";
 $seg_len = 0;
 gen_3_files();

 open (rd_cmd, 'temp_cmd.txt');
 open (rd_cmd_len, 'temp_cmd_len.txt');
 open (rd_spep,'temp_spep.txt');
 open (wr_cmd, '>4ln_cmd_ilk_in.txt');

 @cmd_fl = <rd_cmd>;
 @cmd_flen = <rd_cmd_len>;
 chop @cmd_fl;
 chop @cmd_flen;
 $cmd_ptr=0;
 $c_len = 0;
 while(<rd_spep>)
 {
    chomp($_);
    $_ =~ s/\r//g;

    @status = split('',$_);

#    $c_len = @cmd_flen[$cmd_ptr];
    $cmd_ptr_pre = ($cmd_ptr - 1);

   if($status[0]==1){
                      print wr_cmd @cmd_fl[$cmd_ptr];
                      $c_len = @cmd_flen[$cmd_ptr];
                      $cmd_ptr++;
                     }
   elsif($status[1]==1) 
       {
       if($c_len==20) {print wr_cmd "0000000000";}
       elsif ($c_len==31) {print wr_cmd "0000000080";}
       elsif ($c_len==32) {print wr_cmd "0000000080";}
       elsif ($c_len==55) {print wr_cmd "0000000080";}
       elsif ($c_len==74) {print wr_cmd "0000000080";}
       elsif ($c_len==85) {print wr_cmd "0000000000";}
       elsif (($c_len==96) || (@cmd_flen[$cmd_ptr_pre] == 96)){print wr_cmd "0000000080";}
       else {print wr_cmd "0000000000";};
       }
   else {print wr_cmd "0000000000";}

   if($status[2]==1){
                      print wr_cmd @cmd_fl[$cmd_ptr];
                      $c_len = @cmd_flen[$cmd_ptr];
                      $cmd_ptr++;
                     }
   elsif($status[3]==1) 
       {
       if($c_len==20) {print wr_cmd "0000000000";}
       elsif ($c_len==31) {print wr_cmd "0000000080";}
       elsif ($c_len==32) {print wr_cmd "0000000080";}
       elsif ($c_len==55) {print wr_cmd "0000000080";}
       elsif ($c_len==74) {print wr_cmd "0000000080";}
       elsif ($c_len==85) {print wr_cmd "0000000000";}
       elsif (($c_len==96) || (@cmd_flen[$cmd_ptr_pre] == 96)){print wr_cmd "0000000080";}
       else {print wr_cmd "0000000000";};
        }
   else {print wr_cmd "0000000000";}

   if($status[4]==1){
                      print wr_cmd @cmd_fl[$cmd_ptr];
                      $c_len = @cmd_flen[$cmd_ptr];
                      $cmd_ptr++;
                     }
   elsif($status[5]==1) 
       {
       if($c_len==20) {print wr_cmd "0000000000";}
       elsif ($c_len==31) {print wr_cmd "0000000080";}
       elsif ($c_len==32) {print wr_cmd "0000000080";}
       elsif ($c_len==55) {print wr_cmd "0000000080";}
       elsif ($c_len==74) {print wr_cmd "0000000080";}
       elsif ($c_len==85) {print wr_cmd "0000000000";}
       elsif (($c_len==96) || (@cmd_flen[$cmd_ptr_pre] == 96)){print wr_cmd "0000000080";}
       else {print wr_cmd "0000000000";};
        }
   else {print wr_cmd "0000000000";}

   if($status[6]==1){
                      print wr_cmd @cmd_fl[$cmd_ptr];
                      $c_len = @cmd_flen[$cmd_ptr];
                      $cmd_ptr++;
                     }
   elsif($status[7]==1) 
       {
       if($c_len==20) {print wr_cmd "0000000000";}
       elsif ($c_len==31) {print wr_cmd "0000000080";}
       elsif ($c_len==32) {print wr_cmd "0000000080";}
       elsif ($c_len==55) {print wr_cmd "0000000080";}
       elsif ($c_len==74) {print wr_cmd "0000000080";}
       elsif ($c_len==85) {print wr_cmd "0000000000";}
       elsif (($c_len==96) || (@cmd_flen[$cmd_ptr_pre] == 96)){print wr_cmd "0000000080";}
       else {print wr_cmd "0000000000";};
        }
   else {print wr_cmd "0000000000";}

   #print @status,"\t",$c_len,"\t",@cmd_fl[$cmd_ptr-1],"\n";

   print wr_cmd "\n";
 }
 close (rd_cmd); 
 close (rd_cmd_len); 
 close (wr_cmd);
 close (rd_spep); 

####################

 open (rd_spep,'temp_spep.txt');
 open (up_spep, '>sop_eop_in'.$dual_port.".txt");

 while(<rd_spep>)
 {
   chomp($_);
   $_ =~ s/\r//g;

   $str = $_;
   @bin_array = map { unpack ('B*', pack ('B*',$_)) } split ':', $str;
   $bin_data=arraystring(@bin_array[0..7]);
   $dec = stringdecimal($bin_data);
   $hex = sprintf("%02x", $dec);
  
   print up_spep $hex,"\n";
 }
 close (rd_spep); 
 close (up_spep);

 unlink("temp_cmd.txt");
 unlink("temp_cmd_len.txt");
 unlink("temp_spep.txt");

 
 #================================================
 #######====Golden_ref file Generation======######
 #================================================
#chdir "../";
chdir $my_pwd;
 $filename2 = shift;
 print "output File: ",$filename2,"\n";
 open (MYFILE, "$filename2") or die "couldnot open the file: \"$filename2\" \n";
#chdir "./txt_out";
 chdir $txt_out;

 @v_MYFILE = <MYFILE>;
 $data = "t_golden_ref_data".$dual_port.".txt";
 $cmd  = "temp_cmd_out.txt";
 $spep = "temp_spep_out.txt";
 gen_3_files(); 

 unlink("temp_spep_out.txt");

 open (rd_cmd_o, 'temp_cmd_out.txt');
 open (gold_cmd_t, '>golden_ref_cmd'.$dual_port.".txt");
 $cmd_ptr=0;
 
 while(<rd_cmd_o>)
 {
    chop($_);
    chop($_);
    chop($_);
    $_ =~ s/\r//g;
	
	my @ref_cmd = split('',$_);
	#if(@ref_cmd[7] == 1) {
	if(0 == 1) {
		print gold_cmd_t $_;
		$cmd_ptr++;
		if($cmd_ptr%4==0){print gold_cmd_t "\n"};
		print gold_cmd_t "00000000";
		$cmd_ptr++;
		if($cmd_ptr%4==0){print gold_cmd_t "\n"};
		print gold_cmd_t "00000000";
		$cmd_ptr++;
		if($cmd_ptr%4==0){print gold_cmd_t "\n"};		
	}
	else {
		print gold_cmd_t $_;
		$cmd_ptr++;
		if($cmd_ptr%4==0){print gold_cmd_t "\n"};
	}
 }

 close (rd_cmd_o);
 close (gold_cmd_t);

 unlink("temp_cmd_out.txt");

 #===== FF...FFF at last but 1 line in GOLDEN REF DATA ===

 open (gold_data, '>golden_ref_data'.$dual_port.".txt");
 open (read_data1,'t_golden_ref_data'.$dual_port.".txt");

 @F_data_fl = <read_data1>;
 $num_lines = $#F_data_fl - 1;
 
  print "rx_linecount : ", $#F_data_fl+1, "\n";
  
  open (rx_cnt, '>rx_linecount'.$dual_port.".txt");
  printf rx_cnt "w 1f.1.3 %x", $num_lines;
  close (rx_cnt);

  $cnt1=0;
  for(0..$#F_data_fl)
  {
    if(@F_data_fl[$cnt1] !~ s/\r//g) {
		print gold_data @F_data_fl[$cnt1];
	}
    $cnt1++;

    #if($cnt1 eq $num_lines-3)
    #{
    #  for(1..128){print gold_data "F";}
    #  print gold_data "\n";
    #}
  }
 close (gold_data);
 close (read_data1);

unlink("t_golden_ref_data".$dual_port.".txt");


####=== FF...FFF at last but 1 line in command file ========
 open (rd_cmd_4, '4ln_cmd_ilk_in.txt');
 open (wr_cmd_F,'>cmd_ilk_in'.$dual_port.".txt");
   
 @F_cmd_fl = <rd_cmd_4>;
 $cmd_num_lines = $#F_cmd_fl;

  print "tx_linecount : ", $#F_cmd_fl+1, "\n";
  open (tx_cnt, '>tx_linecount'.$dual_port.".txt");
  printf tx_cnt "w 1f.1.2 %x", $cmd_num_lines;
  close (tx_cnt);

  $cnt=0;
  for(0..$#F_cmd_fl)
  {
    
    print wr_cmd_F @F_cmd_fl[$cnt];
    $cnt++;
  
    #if($cnt eq $cmd_num_lines-1)
    #{
    #  print wr_cmd_F "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF","\n";
    #}
  }
 close (rd_cmd_4);
 close (wr_cmd_F);

unlink("4ln_cmd_ilk_in.txt");
unlink("temp_cmd_len.txt");

print "come here!\n";
open(EX_FILE0, "cmd_ilk_in".$dual_port.".txt");
open(EX_FILE1, "data_ilk_in".$dual_port.".txt");
open(EX_FILE2, "sop_eop_in".$dual_port.".txt");
open(OUT_FILE0, ">sim_cmd_ilk_in".$dual_port.".txt");
open(OUT_FILE1, ">sim_data_ilk_in".$dual_port.".txt");
open(OUT_FILE2, ">sim_sop_eop_in".$dual_port.".txt");

open (OUT_FILE3, ">npu_tx_linecount".$dual_port.".txt");
printf OUT_FILE3 "%x", ($cmd_num_lines+1)*2-1;


@a_file0 = <EX_FILE0>;

foreach(@a_file0) {
        chomp($_);
    $_ =~ s/\r//g;
        @a_sp0=split('',$_);
        $line_00 = join('',@a_sp0[0..19]);
        $line_01 = join('',@a_sp0[20..39]);
        printf OUT_FILE0 $line_00."00000000000000000000\n";
        printf OUT_FILE0 $line_01."00000000000000000000\n";
}

@a_file1 = <EX_FILE1>;

foreach(@a_file1) {
        chomp($_);
    $_ =~ s/\r//g;
        @a_sp0=split('',$_);
        $line_00 = join('',@a_sp0[0..63]);
        $line_01 = join('',@a_sp0[64..127]);
        printf OUT_FILE1 $line_00."0000000000000000000000000000000000000000000000000000000000000000\n";
        printf OUT_FILE1 $line_01."0000000000000000000000000000000000000000000000000000000000000000\n";
}

@a_file2 = <EX_FILE2>;

foreach(@a_file2) {
        chomp($_);
    $_ =~ s/\r//g;
        @a_sp0=split('',$_);
        $line_00 = join('',@a_sp0[0]);
        $line_01 = join('',@a_sp0[1]);
        printf OUT_FILE2 $line_00."0\n";
        printf OUT_FILE2 $line_01."0\n";
}

close (OUT_FILE0);
close (OUT_FILE1);
close (OUT_FILE2);
close (OUT_FILE3);

#rename ('sim_cmd_ilk_in'.$dual_port.'.txt', 'cmd_ilk_in'.$dual_port.'.txt') || die ("Error in renaming");
#rename ('sim_data_ilk_in'.$dual_port.'.txt', 'data_ilk_in'.$dual_port.'.txt') || die ("Error in renaming");
#rename ('sim_sop_eop_in'.$dual_port.'.txt', 'sop_eop_in'.$dual_port.'.txt') || die ("Error in renaming");
#rename ('npu_tx_linecount'.$dual_port.'.txt', 'tx_linecount'.$dual_port.'.txt') || die ("Error in renaming");

chdir "../";

#=====================================================================
################=====SUBROUTINES=====#################################
#=====================================================================

 #====== SUB to generate 3 fiels ==========
sub gen_3_files{
 open (MYFILE1, ">$data");
 open (MYFILE2, ">$cmd");
 open (MYFILE3, ">$spep");
 open (MYFILE4, ">$cmd_len");

 my $i = 0;
 my $k = 0;
 my $j = 0;
 my $l = 0;
 my $m = 0;
 my $te;
 my $save_line;
 my $hex = 0;
 my $spep_ptr=0; 
 my $return=0;


 $seq_len = 0;	
 
 foreach(@v_MYFILE) 
 {

	chomp($_);
    $_ =~ s/\r//g;

	if($_ !~ /\#/) {
       $return = 0;
	   @nibbles=split('',$_);

       $save_line = join('',@nibbles[1..16]);

	   if($nibbles[0] == 5) {
			open (dual_config, '>dual_port_reg'.$dual_port.".txt");
			printf dual_config "w 1e.3.2c ".@nibbles[13].@nibbles[14].@nibbles[15].@nibbles[16];
			close (dual_config);
	   }
	   if($nibbles[0] == 4) {
			open (ad0, '>ad_sel0'.$dual_port.".txt");
			printf ad0 "w 1e.3.2e ".@nibbles[13].@nibbles[14].@nibbles[15].@nibbles[16];
			close (ad0);
			open (ad1, '>ad_sel1'.$dual_port.".txt");
			printf ad1 "w 1e.3.30 ".@nibbles[9].@nibbles[10].@nibbles[11].@nibbles[12];
			close (ad1);
			open (ad2, '>ad_sel2'.$dual_port.".txt");			
			printf ad2 "w 1e.3.32 ".@nibbles[5].@nibbles[6].@nibbles[7].@nibbles[8];
			close (ad2);	
			open (ad3, '>ad_sel3'.$dual_port.".txt");			
			printf ad3 "w 1e.3.34 ".@nibbles[1].@nibbles[2].@nibbles[3].@nibbles[4];
			close (ad3);			
	   }	   	   
	   if($nibbles[0] == 1) {
				$l ++;
	   }
	   
       #displaying control info
       if($nibbles[0] == 2){
           print MYFILE4 $nibbles[15].$nibbles[16],"\n";
		   #print MYFILE4 $nibbles[15].$nibbles[16],"\n";
           if($i==1){
             $k = $k+1;
             printf MYFILE1 $te."0000000000000000";
             $seg_len = $seg_len+1;
             if($k % 4 == 0){printf MYFILE1 "\n";}
             $i=0;
           }
           $str = $_;
           my @bin_cmd = map { unpack ('B*', pack ('H*',$_)) } split ':', $str;
           my @bin_array = split('',@bin_cmd[0]);
           my @part_array =reverse(@bin_array[4..67]);

           if($j != 0){

               print MYFILE2 $m.$seg_len,"\n";

               #displaying sop_eop status
               sop_eop_stat();
           } #end of (j!=0)
           $j=$j+1;

           my $bin = arraystring ("000".reverse(@part_array[42..56]).reverse(@part_array[33..38]).reverse(@part_array[24..31]));
           my $dec = stringdecimal($bin);
           my $hex = sprintf("%08x", $dec);

           print MYFILE2 $hex;
           $seg_len = 0;
       }

       #displaying data info
       if($nibbles[0] == 1){
          $i=$i+1;

          if($i==1){
             $te=join('',@nibbles[1..16]);#$save_line;
          }
          if($i==2){
             $k = $k+1;
             printf MYFILE1 $te.$save_line;
             $seg_len = $seg_len+1;
             if($k % 4 == 0){printf MYFILE1 "\n";}
             $i=0;
          }
       }
    }
}
 
	#printf "INFO: i=$i j=$j k=$k\ seg_len=$seg_len\n";
	if($i==1){
		$k = $k+1;
		printf MYFILE1 $te."0000000000000000";
		$seg_len = $seg_len+1;
		if($k % 4 == 0){printf MYFILE1 "\n";}
		$i=0;
	}	
	if($j != 0){
		print MYFILE2 $m.$seg_len,"\n";
		#displaying sop_eop status
		sop_eop_stat();
	}
	
	$kmod = 4 - $k%4;
	#printf "INFO kmod=$kmod\n";
	for(my $loop=0; $loop<$kmod; $loop++) {
		#printf "INFO 1\n";
		printf MYFILE2 "0000000001\n";
		printf MYFILE1 "00000000000000000000000000000000";
		printf MYFILE4 "20\n";	
		$seg_len = 1;
		sop_eop_stat();
	}
	printf MYFILE1 "\n";	
	if($out_flag==1)
	{
	$add_nops = $add_nops_out;
	print "add nop = $add_nops\n";
	}
	else
	{
	$add_nops = $add_nops_in;
	print "add nop = $add_nops\n";
	}
	for(my $cpl_num=0; $cpl_num<$add_nops; $cpl_num++) {
		printf MYFILE2 "0000000001\n0000000001\n0000000001\n0000000001\n";
		printf MYFILE1 "00000000000000000000000000000000"."00000000000000000000000000000000"."00000000000000000000000000000000"."00000000000000000000000000000000";
		printf MYFILE4 "20\n";	
		$seg_len = 1;
		sop_eop_stat();	
		sop_eop_stat();	
		sop_eop_stat();	
		sop_eop_stat();	
		printf MYFILE1 "\n";
	}
	#printf MYFILE2 "\n";
	#printf MYFILE1 "\n";	
  
	#end of foreach loop
	#printf " Total number of cmd line with LC $l \n";
	close (MYFILE); 
	close (MYFILE1); 
	close (MYFILE2); 
	close (MYFILE3); 
	close (MYFILE4); 
}#end of subroutine gen_3_files

#====== END of SUB which generate 3 fiels ==========

  sub stringdecimal {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
  }

  sub arraystring {
     my $string = join('', @_);
     return $string;
  }


 #displaying sop_eop status
 sub sop_eop_stat{
     if($seg_len==1) {
        $spep_ptr++;
        print MYFILE3 "11";
        if($spep_ptr==4) {$spep_ptr=0;print MYFILE3 "\n";}
     }
  
     #seg_len = 2
     elsif($seg_len==2) {
         if($spep_ptr<3) {
            $spep_ptr+=2;
            print MYFILE3 "1001";
            if($spep_ptr==4) {$spep_ptr=0;print MYFILE3 "\n";}
         }
         else {
            print MYFILE3 "10\n";
            $spep_ptr = 0;
            print MYFILE3 "01";
            $spep_ptr++;
         }
     }
   
     #seg_len = 3
     elsif($seg_len==3) {
         if($spep_ptr<2) {
            print MYFILE3 "100001";
            $spep_ptr+=3;
            if($spep_ptr==4) {$spep_ptr=0;print MYFILE3 "\n";}
         }
         elsif($spep_ptr==2){
            print MYFILE3 "1000\n";
            $spep_ptr = 0;
  
            print MYFILE3 "01";
            $spep_ptr++;
         }
         else {
            print MYFILE3 "10\n";
            $spep_ptr = 0;
  
            print MYFILE3 "0001";
            $spep_ptr+=2;
         }
     } #end of seg_len3
  
     #seg_len = 4
     elsif($seg_len==4) {
         if($spep_ptr==0) {
            print MYFILE3 "10000001\n";
            $spep_ptr=0;
         }
         elsif($spep_ptr==1){
            print MYFILE3 "100000\n";
            $spep_ptr = 0;
  
            print MYFILE3 "01";
            $spep_ptr++;
         }
  
         elsif($spep_ptr==2){
            print MYFILE3 "1000\n";
            $spep_ptr = 0;
  
            print MYFILE3 "0001";
            $spep_ptr+=2;
         }
         else {
            print MYFILE3 "10\n";
            $spep_ptr = 0;
  
            print MYFILE3 "000001";
            $spep_ptr+=3;
         }
     } #end of seg_len4
  
     #seg_len = 5
     else{
         if($spep_ptr==0) {
            print MYFILE3 "10000000\n";
            $spep_ptr=0;
  
            print MYFILE3 "01";
            $spep_ptr++;
         }
  
         elsif($spep_ptr==1){
            print MYFILE3 "100000\n";
            $spep_ptr = 0;
  
            print MYFILE3 "0001";
            $spep_ptr+=2;
         }
  
         elsif($spep_ptr==2){
            print MYFILE3 "1000\n";
            $spep_ptr = 0;
  
            print MYFILE3 "000001";
            $spep_ptr+=3;
         }
  
         else {
            print MYFILE3 "10\n";
            $spep_ptr = 0;
  
            print MYFILE3 "00000001\n";
            $spep_ptr=0;
         }
     } #end of seg_len5
 }






