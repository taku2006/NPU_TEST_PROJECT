#!/usr/local/bin/perl
 #system "rm -rf";
 use File::Basename;
 use Cwd;
 $my_pwd=getcwd;
 print "----------------Enter proc_512_ipf.pl----------------\n";
 print "current work path is: ",$my_pwd,"\n";
 #print "Input ARGV[2] is: ",@ARGV[2],"\n";
 #print "Input ARGV[2] type 2 is: ",$ARGV[2],"\n";
 $dual_port = @ARGV[1];
 print "Dual Port parameter is: ",$dual_port,"\n";
 $workdir=shift;
 #print "workdir is :",$workdir,"\n";
 $txt_out = $workdir."\\txt_out";
 print "txt_out path is :", $txt_out,"\n";
 #mkdir $txt_out;
 #chdir "./txt_out";
 chdir $txt_out;
 print "Enter into txt_out, now the workdir is: ".$getcwd."\n";

#added function to gen new npu need
my $m_sopeop = "sop_eop_in".$dual_port.".txt";
my $m_cmd_in = "cmd_ilk_in".$dual_port.".txt";
my $m_data_in = "data_ilk_in".$dual_port.".txt";
my $m_data_out = "golden_ref_data".$dual_port.".txt";
open(f_sopeop, $m_sopeop) or die "can't open file '$m_sopeop' for read. $!";
open(f_cmd_in, $m_cmd_in) or die "can't open file '$m_cmd_in' for read. $!";
open(f_data_in, $m_data_in) or die "can't open file '$m_data_in' for read. $!";
open(f_data_out, $m_data_out) or die "can't open file '$m_data_out' for read. $!";
open(o_new_in, ">new_in".$dual_port.".txt");
open(o_new_out, ">new_out".$dual_port.".txt");
open(o_new_cfg, ">new_cfg".$dual_port.".ini");

my @v_data_in = <f_data_in>;
my @v_sopeop = <f_sopeop>;
my @v_cmd_in = <f_cmd_in>;
my @v_data_out = <f_data_out>;
my $k = 0;
my $str;
my $tx;
my $rx;
my @a_tx;
my @a_rx;
my $add_1 = 1;
chop(@v_sopeop);
chop(@v_data_in);
chop(@v_cmd_in);


if(($#v_data_in+1)%2 == 1) {
	print "DEBUG0\n";
	$add_1 = 0;
	push @v_sopeop, "00";
	push @v_cmd_in, "0000000000000000000000000000000000000000";
	push @v_data_in, "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
}

print "total data num: ", $#v_data_in+1;
print "\n";

for(0..($#v_data_in+1)/2) {
	$str = "0000000000000000000000".$v_cmd_in[$k].$v_sopeop[$k];
	$str = "0000000000000000000000".$v_cmd_in[$k+1].$v_sopeop[$k+1].$str;
	printf o_new_in $str."\n";
	printf o_new_in $v_data_in[$k]."\n";
	printf o_new_in $v_data_in[$k+1]."\n";	
	#printf o_new_in $k."=".$v_data_in[$k+1]."\n";
	$k = $k + 2;
	last if($k == $#v_data_in+1);
}

foreach(@v_data_out) {
	printf o_new_out $_;
}

$tx = sprintf("%08x", ($#v_data_in + $add_1));
$rx = sprintf("%08x", ($#v_data_out));
@a_tx=split('', $tx);
@a_rx=split('', $rx);
$tx = join('', @a_tx[4..7]);
#printf o_new_cfg "source powerup.ini\nsource align_spsb.ini\n";
if($dual_port =~ /_2/){##Port 2
	printf o_new_cfg "w 1f.1.14 ".$tx."\n";
	$tx = join('', @a_tx[0..3]);
	printf o_new_cfg "w 1f.1.34 ".$tx."\n";
	$rx = join('', @a_rx[4..7]);
	printf o_new_cfg "w 1f.1.15 ".$rx."\n";
	$rx = join('', @a_rx[0..3]);
	printf o_new_cfg "w 1f.1.35 ".$rx."\n";
}
else {
	printf o_new_cfg "w 1f.1.2 ".$tx."\n";
	$tx = join('', @a_tx[0..3]);
	printf o_new_cfg "w 1f.1.22 ".$tx."\n";
	$rx = join('', @a_rx[4..7]);
	printf o_new_cfg "w 1f.1.3 ".$rx."\n";
	$rx = join('', @a_rx[0..3]);
	printf o_new_cfg "w 1f.1.23 ".$rx."\n";
}

#printf o_new_cfg "testtx\n".
#                  "testrx\n".
#                  "w 1f.1.1 0001\n".
#                  "r 1f.2.5f0\n".
#                  "r 1f.2.5e6\n".
#                  "r 1e.2.5f0\n".
#                  "r 1e.2.5e6\n".
#                  "r 1f.1.4\n";

close(f_sopeop);
close(f_cmd_in);
close(f_data_in);
close(f_data_out);
close(o_new_in);
close(o_new_out);
close(o_new_cfg);


