 #!/usr/local/bin/perl
 #use strict;
 #use Spreadsheet::ParseExcel;
 #use Spreadsheet::WriteExcel;
 use Excel::Writer::XLSX;
 use Cwd;
 use Getopt::Long;
 use POSIX;

 my $help = 0;
 my $mode = "spsb";
 my $row_num = 0;
 GetOptions(
  'help|h!' => \$help,
  'mode|m=s' => \$mode,
 );
 if($help){
 	print "This program will write result to 2 excels.\n";
 	print "1. Write to new sheet of existing excel SPSB_RESULT.xls or DPDB_RESULT.xlsx or DPSB_RESULT.xlsx based on the mode\n";
 	print "2. Write to new excel which is named by $mode_res.xlsx\n";
 	print "use -m to point the mode, the valid options has spsb, dpdb,dpsb\n";
 }
 my $year_month_day=strftime("%Y%m%d",localtime());
 ###Write Excel
 #open my $fp_col_res, '>> '.$mode."_COL_RES.xls" or die "Fail to open filehandle: $!";
 #open my $fp_res, '> '.$mode."_res.xls" or die "Fail to open filehandle: $!";
 #my $col_workbook = Spreadsheet::WriteExcel->new($fp_col_res);
 #my $col_worksheet = $col_workbook->add_worksheet($mode."_".$year_month_day);
 #my $sig_workbook = Spreadsheet::WriteExcel->new($fp_res);
 my $sig_workbook = Excel::Writer::XLSX->new($mode."_".$year_month_day.".xlsx");
 my $sig_worksheet = $sig_workbook->add_worksheet();

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
$sig_worksheet->set_column('A:A', 20);
$sig_worksheet->set_column('B:B', 21);
###Write cells
$sig_worksheet->write($row_num,0,"CASE_NUM",$format_head);
$sig_worksheet->write($row_num,1,"RESULT",$format_head);
$row_num++;
for( ; $row_num<11 ; $row_num++){
	$sig_worksheet->write($row_num,0,"CASE_".$row_num,$format_1);
	$sig_worksheet->write($row_num,1,"PASS",$format_1);
}
print "Excel Write Done\n";
$sig_workbook->close();
#$col_workbook->close();
